import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/shared/services/notification_service.dart';
import 'package:icon_broken/icon_broken.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:social_media_app/models/create_post_impl_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:social_media_app/models/post_model.dart';
import 'package:social_media_app/models/user_model.dart';
import 'package:social_media_app/modules/chat/chats_body.dart';
import 'package:social_media_app/modules/feeds/feeds_body.dart';
import 'package:social_media_app/modules/new_post/new_post.dart';
import 'package:social_media_app/modules/notifications/notifications_body.dart';
import 'package:social_media_app/modules/my_account/my_account_body.dart';
import 'package:social_media_app/shared/components/constants.dart';
import 'package:social_media_app/shared/network/local/cache_helper.dart';
import '../../../models/like_model.dart';
import '../../../models/update_user_impl_model.dart';
import 'package:social_media_app/models/notification_model.dart';
part 'social_state.dart';

class SocialCubit extends Cubit<SocialState> {
  // Cached UID token for the logged-in user from local storage
  String? uidTokenCache;

  SocialCubit() : super(SocialInitial()) {
    _initializeUidToken();
    _startNotificationListener();
  }

  // To track unread notifications for the badge
  bool hasUnreadNotifications = false;
  bool hasUnreadMessages = false;

  StreamSubscription? _messagesUnreadSubscription;
  StreamSubscription? _notificationsUnreadSubscription;

  void _startNotificationListener() {
    // 1. Listen for background/foreground FCM messages (already partially here)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data['type'] == 'message') {
        final senderUid = message.data['uid'];
        if (senderUid != null) {
          _markMessagesAsDelivered(senderUid);
        }
        if (currentBottomNavBarIndex != 1) {
          hasUnreadMessages = true;
          emit(BottomNavBarState());
        }
      } else {
        if (currentBottomNavBarIndex != 4) {
          hasUnreadNotifications = true;
          emit(BottomNavBarState());
        }
      }
    });

    // 2. Listen to Firestore for ACTUAL unread status (covers app restarts and sync)
    _listenForFirestoreUnreadStates();
  }

  void _listenForFirestoreUnreadStates() {
    _messagesUnreadSubscription?.cancel();
    _notificationsUnreadSubscription?.cancel();

    // Listen to chats for any isRead == false
    _messagesUnreadSubscription = FirebaseFirestore.instance
        .collection(kUsersCollection)
        .doc(currentUserUid)
        .collection(kChatCollection)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((event) {
      if (currentBottomNavBarIndex != 1) {
        hasUnreadMessages = event.docs.isNotEmpty;
        emit(BottomNavBarState());
      }
    });

    // Listen to notifications for any isRead == false
    _notificationsUnreadSubscription = FirebaseFirestore.instance
        .collection(kUsersCollection)
        .doc(currentUserUid)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((event) {
      if (currentBottomNavBarIndex != 4) {
        hasUnreadNotifications = event.docs.isNotEmpty;
        emit(BottomNavBarState());
      }
    });
  }

  // Initialize the cached UID token
  void _initializeUidToken() {
    uidTokenCache = CacheHelper.getData(key: kUidToken);
  }

  // Get the current user UID, preferring the cached token if available
  String get currentUserUid =>
      uidTokenCache ?? FirebaseAuth.instance.currentUser!.uid;

  // Get current user email for optional debugging
  String? get currentUserEmail => FirebaseAuth.instance.currentUser?.email;

  // Current index for bottom navbar selection
  int currentBottomNavBarIndex = 0;

  // Change current index of the bottom navbar and emit state
  void changeBottomNavBar(int value) {
    if (value == 4) {
      hasUnreadNotifications = false;
    }
    if (value == 1) {
      hasUnreadMessages = false;
    }
    currentBottomNavBarIndex = value;
    emit(BottomNavBarState());
  }

  void _markMessagesAsDelivered(String senderUid) async {
    try {
      final messagesRef = FirebaseFirestore.instance
          .collection(kUsersCollection)
          .doc(currentUserUid)
          .collection(kChatCollection)
          .doc(senderUid)
          .collection(kMessageCollection);

      final unreadMessages = await messagesRef
          .where('uid', isEqualTo: senderUid)
          .where('isDelivered', isEqualTo: false)
          .get();

      for (var doc in unreadMessages.docs) {
        // Update receiver's copy
        await doc.reference.update({'isDelivered': true});

        // Update sender's copy
        await FirebaseFirestore.instance
            .collection(kUsersCollection)
            .doc(senderUid)
            .collection(kChatCollection)
            .doc(currentUserUid)
            .collection(kMessageCollection)
            .doc(doc.id)
            .update({'isDelivered': true});
      }

      // Also update chat preview for both
      await FirebaseFirestore.instance
          .collection(kUsersCollection)
          .doc(currentUserUid)
          .collection(kChatCollection)
          .doc(senderUid)
          .update({'isDelivered': true});

      await FirebaseFirestore.instance
          .collection(kUsersCollection)
          .doc(senderUid)
          .collection(kChatCollection)
          .doc(currentUserUid)
          .update({'isDelivered': true});
    } catch (e) {
      // debugPrint("Error marking as delivered: $e");
    }
  }

  // List of widgets shown in the body based on the current navbar index
  final List<Widget> currentBody = const [
    FeedsBody(),
    ChatsBody(),
    CreatePostSheet(),
    UsersBody(),
    NotificationsBody(),
  ];

  // Bottom navigation bar items
  // Bottom navigation bar items
  List<BottomNavigationBarItem> get bottomNavigationBarItem => [
        const BottomNavigationBarItem(icon: Icon(IconBroken.Home), label: ''),
        BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Stack(
                children: [
                  const Icon(IconBroken.Chat),
                  if (hasUnreadMessages)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 8,
                          minHeight: 8,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            label: ''),
        const BottomNavigationBarItem(
            icon: SizedBox(
              width: 35,
            ),
            label: ''),
        const BottomNavigationBarItem(
            icon: Icon(IconBroken.Profile), label: ''),
        BottomNavigationBarItem(
          icon: Stack(
            children: [
              const Icon(IconBroken.Notification),
              if (hasUnreadNotifications)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 8,
                      minHeight: 8,
                    ),
                  ),
                ),
            ],
          ),
          label: '',
        ),
      ];

  // Current Firebase User for email verification
  User? userVerification = FirebaseAuth.instance.currentUser;

  // Send a verification email to the current user
  Future<void> sendEmailVerification() async {
    emit(SendEmailVerificationLoadingState());
    try {
      if (userVerification == null) {
        emit(
            SendEmailVerificationFailureState(errMessage: 'No user logged in'));
        return;
      } else {
        await userVerification!.sendEmailVerification();
        emit(SendEmailVerificationSuccessState(
            message: 'Email sent successfully to ${userVerification!.email}'));
      }
    } catch (e) {
      emit(SendEmailVerificationFailureState(errMessage: e.toString()));
    }
  }

  // Checks the current user's email verification status
  Future<void> checkEmailStatus() async {
    emit(CheckEmailLoadingState());
    try {
      // Reload to ensure the latest verification status
      await FirebaseAuth.instance.currentUser?.reload();
      userVerification = FirebaseAuth.instance.currentUser;

      if (userVerification != null && userVerification!.emailVerified) {
        emit(CheckEmailSuccessState());
      } else {
        emit(
          SendEmailVerificationFailureState(
            errMessage: 'You didn\'t verify your account',
          ),
        );
      }
    } catch (e) {
      emit(CheckEmailErrorState(e.toString()));
    }
  }

  // UserModel for the currently logged-in user
  UserModel? userModel;

  // Firestore collection references
  final _postCollectionRef =
      FirebaseFirestore.instance.collection(kPostsCollection);
  final _userCollectionRef =
      FirebaseFirestore.instance.collection(kUsersCollection);

  // Fetch user data from Firestore and update [userModel]
  Future<UserModel?> getUserData(
      {required String userUid, bool emitState = true}) async {
    if (emitState) emit(GetMyDataLoadingState());
    try {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await _userCollectionRef.doc(userUid).get();

      if (documentSnapshot.exists && documentSnapshot.data() != null) {
        Map<String, dynamic> userModelData = documentSnapshot.data()!;
        UserModel specificUserModel = UserModel.fromJson(userModelData);
        // Only update userModel if it's the first time or the current user's data is required
        if (userModel == null || userModel!.uid == userUid) {
          userModel = specificUserModel;
          await getReportedPosts();
          // Use NotificationService instead of updateFCMToken
          await NotificationService().saveFCMToken(userUid);
        }
        if (emitState) emit(GetMyDataSuccessState());
        return specificUserModel;
      } else {
        if (emitState) {
          emit(GetMyDataFailureState(errMessage: "User data not found"));
        }
        return null;
      }
    } catch (e) {
      if (emitState) emit(GetMyDataFailureState(errMessage: e.toString()));
      return null;
    }
  }

  // TextEditingControllers for user profile editing
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController birthdayController = TextEditingController();
  String? updatedYear;
  String? updatedDayAndMonth;

  // Update user information in Firestore
  Future<void> updateUserInfo(
      {required UpdateUserImplModel updateUserImplModel}) async {
    emit(UpdateUserInfoLoadingState());
    try {
      await _userCollectionRef
          .doc(currentUserUid)
          .update(updateUserImplModel.toMap(userModel!));
      userModel = null;
      await getUserData(userUid: currentUserUid);
    } on Exception catch (err) {
      emit(UpdateUserInfoFailureState(errMessage: err.toString()));
    }
  }

  /// Picks an image from the gallery and returns a File to be used in the app.
  /// Handles permission requirements for Android 13+ and earlier versions.
  ///
  /// Requests the appropriate permissions based on platform and Android version:
  ///   - Android 13+ uses [Permission.photos]
  ///   - Android 12 and below use [Permission.storage]
  ///   - Other platforms use [Permission.photos]
  ///
  /// If permission is denied, it attempts to request again.
  /// If permission is permanently denied, sends the user to the app settings.
  /// Emits a failure state if unable to proceed.
  Future<File?> pickImage() async {
    PermissionStatus status;

    // Check platform and request the correct permission
    if (Platform.isAndroid) {
      final androidVersion = await _getAndroidVersion();

      if (androidVersion >= 33) {
        // Android 13+ (API 33) requires photo permission
        status = await Permission.photos.request();
      } else {
        // Android 12- (API 32 or lower) uses storage permission
        status = await Permission.storage.request();
      }
    } else {
      // Non-Android platforms use photo permission
      status = await Permission.photos.request();
    }

    // Permission granted on the first try
    if (status.isGranted) {
      return await _openGallery();
    }
    // If permission denied, try requesting again depending on platform/version
    else if (status.isDenied) {
      // Retry logic for Android, using correct permission depending on version
      if (Platform.isAndroid && (await _getAndroidVersion()) < 33) {
        // Retry storage permission for Android < 33
        status = await Permission.storage.request();
      } else {
        // Retry photo permission for Android 33+ or other platforms
        status = await Permission.photos.request();
      }

      // If granted on retry, open gallery
      if (status.isGranted) return await _openGallery();
    }
    // If permission permanently denied, prompt user to go to app settings
    else if (status.isPermanentlyDenied) {
      openAppSettings();
    }

    // Permission still denied or failed, emit failure state and return null
    emit(PickImageFailureState(errMessage: "Gallery access permission denied"));
    return null;
  }

  // Helper function to update FCM Token
  Future<void> updateFCMToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null && currentUserUid.isNotEmpty) {
        await _userCollectionRef
            .doc(currentUserUid)
            .update({'fcmToken': token});
      }
    } catch (e) {
      //  debugPrint("Error updating FCM Token: $e");
    }
  }

  // Helper function to open device gallery and allow user to pick an image
  Future<File?> _openGallery() async {
    emit(PickImageLoadingState());
    final ImagePicker picker = ImagePicker();
    final XFile? selectedImage =
        await picker.pickImage(source: ImageSource.gallery);

    if (selectedImage != null) {
      emit(PickImageSuccessState());
      return File(selectedImage.path);
    }
    // User cancelled picker or no image selected
    return null;
  }

  // Helper function to get Android SDK version as an integer (returns 0 if not Android)
  Future<int> _getAndroidVersion() async {
    if (Platform.isAndroid) {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.version.sdkInt;
    }
    return 0;
  }

  // Upload a profile image to Firebase Storage and return its URL
  Future<String?> _uploadProfileImage({required File file}) async {
    emit(UploadProfileImageLoadingState());
    String? pictureUrl;
    try {
      final task = await FirebaseStorage.instance
          .ref()
          .child(
              '$kUsersCollection/$kProfileFolder/${Uri.file(file.path).pathSegments.last}')
          .putFile(file);

      pictureUrl = await task.ref.getDownloadURL();
      emit(UploadProfileImageSuccessState());
      return pictureUrl;
    } on Exception catch (e) {
      emit(UploadProfileImageFailureState(errMessage: e.toString()));
    }
    return pictureUrl;
  }

  // Pick and upload a profile image, then update user's profile photo in Firestore
  Future<String?> pickAndUploadProfileImage() async {
    File? returnedProfileImage = await pickImage();
    if (returnedProfileImage != null) {
      String? profileImageUrl =
          await _uploadProfileImage(file: returnedProfileImage);
      if (profileImageUrl != null) {
        UpdateUserImplModel updateUserImplModel =
            UpdateUserImplModel(photo: profileImageUrl);
        await updateUserInfo(updateUserImplModel: updateUserImplModel);
      }
    }
    return null;
  }

  // Upload a cover image to Firebase Storage and return its URL
  Future<String?> uploadCoverImage({required File file}) async {
    emit(UploadCoverImageLoadingState());
    String? coverUrl;
    try {
      final task = await FirebaseStorage.instance
          .ref()
          .child(
              '$kUsersCollection/$kCoverFolder/${Uri.file(file.path).pathSegments.last}')
          .putFile(file);

      coverUrl = await task.ref.getDownloadURL();
      emit(UploadCoverImageSuccessState());
      return coverUrl;
    } on Exception catch (e) {
      emit(UploadCoverImageFailureState(errMessage: e.toString()));
    }
    return coverUrl;
  }

  // Pick and upload a cover image, then update user's cover photo in Firestore
  Future<String?> pickAndUploadCoverImage() async {
    File? returnedCoverImage = await pickImage();
    if (returnedCoverImage != null) {
      String? coverImageUrl = await uploadCoverImage(file: returnedCoverImage);
      if (coverImageUrl != null) {
        UpdateUserImplModel updateUserImplModel =
            UpdateUserImplModel(cover: coverImageUrl);
        await updateUserInfo(updateUserImplModel: updateUserImplModel);
      }
    }
    return null;
  }

  // Upload a post image to Firebase Storage and return its URL
  Future<String?> _uploadPostImage({required File file}) async {
    emit(CreatePostLoadingState());
    String? postUrl;
    try {
      final task = await FirebaseStorage.instance
          .ref()
          .child(
              '$kUsersCollection/$kPostFolder/${Uri.file(file.path).pathSegments.last}')
          .putFile(file);

      postUrl = await task.ref.getDownloadURL();
      emit(UploadPostImageSuccessState());
      return postUrl;
    } catch (e) {
      emit(UploadPostImageFailureState(errMessage: e.toString()));
    }
    return postUrl;
  }

  // Search for users by username substring query, case-insensitive, limited to 20 users
  // Search for users by username or "First Name + Last Name"
  Future<List<UserModel>?> searchUsers(String query) async {
    emit(SearchUsersLoadingState());
    if (query.trim().isEmpty) return [];

    // Normalize query: lowercase and single spaces
    final String normalizedQuery =
        query.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
    // Keep casing of first word for Capitalized FirstName search
    final List<String> queryParts =
        query.trim().replaceAll(RegExp(r'\s+'), ' ').split(' ');
    final String firstWord = queryParts.isNotEmpty ? queryParts.first : "";

    String capitalizedFirstWord = "";
    if (firstWord.isNotEmpty) {
      capitalizedFirstWord = firstWord.length > 1
          ? firstWord[0].toUpperCase() + firstWord.substring(1).toLowerCase()
          : firstWord.toUpperCase();
    }

    try {
      Map<String, UserModel> usersMap = {};

      // 1. Search by userName (lowercase prefix)
      // Expects userName to be stored in a way that matches lowercase query (or purely lowercase)
      final userNameSnapshot = await FirebaseFirestore.instance
          .collection(kUsersCollection)
          .orderBy('userName')
          .startAt([normalizedQuery])
          .endAt(['$normalizedQuery\uf8ff'])
          .limit(20)
          .get();

      for (var doc in userNameSnapshot.docs) {
        usersMap[doc.id] = UserModel.fromJson(doc.data());
      }

      // 2. Search by firstName (Capitalized prefix)
      if (capitalizedFirstWord.isNotEmpty) {
        final firstNameSnapshot = await FirebaseFirestore.instance
            .collection(kUsersCollection)
            .orderBy('firstName')
            .startAt([capitalizedFirstWord])
            .endAt(['$capitalizedFirstWord\uf8ff'])
            .limit(20)
            .get();

        for (var doc in firstNameSnapshot.docs) {
          if (!usersMap.containsKey(doc.id)) {
            usersMap[doc.id] = UserModel.fromJson(doc.data());
          }
        }
      }

      // 3. Filter results locally to match full name or userName strictly
      final List<UserModel> usersList = usersMap.values.where((user) {
        final String fullName =
            '${user.firstName} ${user.lastName}'.toLowerCase();
        final String userName = user.userName.toLowerCase();

        // Check if query matches the start of username OR start of Full Name
        return userName.startsWith(normalizedQuery) ||
            fullName.startsWith(normalizedQuery);
      }).toList();

      emit(SearchUsersSuccessState());
      return usersList;
    } on Exception catch (e) {
      emit(SearchUsersFailureState(errMessage: e.toString()));
      return null;
    }
  }

  // Create a new post in Firestore
  Future<void> _createPost(CreatePostImplModel createPostImplModel) async {
    emit(CreatePostLoadingState());
    PostModel postModel = PostModel(
      userName: '${userModel!.firstName} ${userModel!.lastName}',
      creatorUid: userModel!.uid,
      profilePhoto: userModel!.photo,
      dateTime: createPostImplModel.dateTime,
      content: createPostImplModel.content,
      postImage: createPostImplModel.postImage,
      commentsNum: createPostImplModel.commentsNum,
    );
    try {
      DocumentReference docRef =
          await _postCollectionRef.add(postModel.toJson());

      // Notify followers about the new post
      _notifyFollowers(postModel, docRef.id);

      postContentController.clear();
      postImagePicked = null;
      emit(CreatePostSuccessState());

      // Refresh posts after successfully creating a new post
      getMyUserPosts(userModel!.uid);
      await getTimelinePosts();
    } catch (err) {
      emit(CreatePostFailureState(errMessage: err.toString()));
    }
  }

  // Helper function to notify followers
  Future<void> _notifyFollowers(PostModel postModel, String postDocId) async {
    try {
      // 1. Get followers
      final followersSnapshot = await _userCollectionRef
          .doc(userModel!.uid)
          .collection(kFollowersCollection)
          .get();

      for (var followerDoc in followersSnapshot.docs) {
        final followerUid = followerDoc.id;

        // 2. Create Notification Model
        final notificationId = DateTime.now().millisecondsSinceEpoch.toString();
        final notification = NotificationModel(
          notificationId: notificationId,
          senderUid: userModel!.uid,
          receiverUid: followerUid,
          senderName: '${userModel!.firstName} ${userModel!.lastName}',
          senderPhoto: userModel!.photo,
          type: 'post',
          content: 'published a new post',
          postId: postDocId,
          isRead: false,
          dateTime: DateTime.now(),
        );

        // 3. Save to Firestore (Follower's notifications)
        await _userCollectionRef
            .doc(followerUid)
            .collection('notifications')
            .doc(notificationId)
            .set(notification.toMap());

        // 4. Send Push Notification
        final followerUserDoc = await _userCollectionRef.doc(followerUid).get();
        if (followerUserDoc.exists) {
          final followerData = followerUserDoc.data();
          if (followerData != null) {
            final String? token = followerData['fcmToken'];
            if (token != null && token.isNotEmpty) {
              await NotificationService().sendNotification(
                receiverToken: token,
                title: '${userModel!.firstName} ${userModel!.lastName}',
                body: 'published a new post',
                senderPhoto: userModel!.photo,
                messageImage: postModel.postImage,
                data: {
                  'type': 'post',
                  'postId': postDocId,
                },
              );
            }
          }
        }
      }
    } catch (e) {
      //  debugPrint('Error notifying followers: $e');
    }
  }

  // Picked post image file
  File? postImagePicked;

  // Controller for the post content field
  TextEditingController postContentController = TextEditingController();

  // Create a post with photo (and optional content)
  Future<void> createPostWithPhoto(
      {required String? postContent,
      required DateTime dateTime,
      required int commentsNum}) async {
    if (postImagePicked != null) {
      String? postImageUrl = await _uploadPostImage(file: postImagePicked!);
      if (postImageUrl != null) {
        CreatePostImplModel createPostImplModel = CreatePostImplModel(
          content: postContent,
          postImage: postImageUrl,
          dateTime: dateTime,
          commentsNum: commentsNum,
        );
        await _createPost(createPostImplModel);
      }
    }
  }

  // Remove the picked post image file
  void removePickedFile() {
    postImagePicked = null;
    emit(RemovePickedFile());
  }

  // Create a post with only content (without image)
  Future<void> createPostWithContentOnly(
      {required String? postContent,
      required DateTime dateTime,
      required int commentsNum}) async {
    CreatePostImplModel createPostImplModel = CreatePostImplModel(
      content: postContent,
      postImage: null,
      dateTime: dateTime,
      commentsNum: commentsNum,
    );
    await _createPost(createPostImplModel);
  }

  // Remove the post image and clear the post content text field during post creation
  void cancelPostDuringCreating() {
    postImagePicked = null;
    postContentController.text = '';
    emit(RemovePostState());
  }

  // Delete a post from Firestore, then refresh post lists
  Future<void> deletePost(String postId) async {
    try {
      await _postCollectionRef.doc(postId).delete();
      getMyUserPosts(userModel!.uid);
      await getTimelinePosts();
      emit(RemovePostState());
    } on Exception catch (e) {
      emit(RemovePostFailureState(errMessage: e.toString()));
    }
  }

  List<String> reportedPostsIds = [];

  Future<void> getReportedPosts() async {
    try {
      var snapshot = await _userCollectionRef
          .doc(currentUserUid)
          .collection(kReportedPostsCollection)
          .get();
      reportedPostsIds = snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      // debugPrint("Error fetching reported posts: $e");
    }
  }

  Future<void> reportPost(
      {required String postId, required String reason}) async {
    try {
      // 1. Hide locally
      if (!reportedPostsIds.contains(postId)) {
        reportedPostsIds.add(postId);
      }

      int friendPostIndex = friendsPostsIdList.indexOf(postId);
      if (friendPostIndex != -1) {
        friendsPostsIdList.removeAt(friendPostIndex);
        friendsPostsModelList.removeAt(friendPostIndex);
      }

      int myPostIndex = myPostsIdList.indexOf(postId);
      if (myPostIndex != -1) {
        myPostsIdList.removeAt(myPostIndex);
        myPostsModelList.removeAt(myPostIndex);
      }

      // 2. Save to Firestore (Users -> Me -> ReportedPosts)
      await _userCollectionRef
          .doc(currentUserUid)
          .collection(kReportedPostsCollection)
          .doc(postId)
          .set({
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 3. Save to Global Reports Collection (for Admin)
      await FirebaseFirestore.instance.collection(kReportsCollection).add({
        'reporterUid': currentUserUid,
        'postId': postId,
        'timestamp': FieldValue.serverTimestamp(),
        'reason': reason,
      });

      // 4. Send Email Intent
      final Uri emailLaunchUri = Uri(
        scheme: 'mailto',
        path: 'codmego@gmail.com',
        query: _encodeQueryParameters(<String, String>{
          'subject': 'Report Post: $postId',
          'body':
              'I want to report the post with ID: $postId.\n\nReason: $reason',
        }),
      );

      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      }

      emit(RemovePostState());
    } on Exception catch (e) {
      emit(RemovePostFailureState(errMessage: e.toString()));
    }
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  // Get UIDs of all users who liked a specific post
  Future<List<String>> _getUsersLikesUidInPost({required String postId}) async {
    List<String> usersLikesUid = [];
    DocumentReference postDocRef = _postCollectionRef.doc(postId);
    var likeCollectionInThePostCollection =
        await postDocRef.collection(kLikesCollection).get();
    var usersLikesUidDocs = likeCollectionInThePostCollection.docs;
    for (var usersUid in usersLikesUidDocs) {
      usersLikesUid.add(usersUid.id);
    }
    return usersLikesUid;
  }

  // List of user models for users who liked a post
  List<UserModel> userModelList = [];

  // Get the user models of all users who liked a specific post
  Future<void> getUsersLikesInPost({required String postId}) async {
    userModelList.clear();
    emit(GetUsersLikesPostLoadingState());

    try {
      List<String> usersLikeUids =
          await _getUsersLikesUidInPost(postId: postId);
      for (var userUid in usersLikeUids) {
        UserModel? userModel =
            await getUserData(userUid: userUid, emitState: false);
        if (userModel != null) {
          userModelList.add(userModel);
        }
      }

      emit(GetUsersLikesPostSuccessState());
    } on Exception catch (e) {
      emit(GetUsersLikesPostFailureState(errMessage: e.toString()));
    }
  }

  // Update the number of comments in a post document in Firestore
  Future<void> updatePostCommentsNum(
      {required int commentsNum, required String postId}) async {
    try {
      await _postCollectionRef.doc(postId).update({'commentsNum': commentsNum});
      emit(UpdateCommentsSuccessState());
    } catch (e) {
      emit(UpdateCommentsFailureState(errMessage: e.toString()));
    }
  }

  // Toggle like/unlike for a post (if [isLike] is true, add; else, remove)
  Future<QuerySnapshot<Map<String, dynamic>>> toggleLike(
      {required String postId,
      required bool isLike,
      required String postCreatorUid}) async {
    emit(ToggleLikeLoadingState());
    DocumentReference postDocRef = _postCollectionRef.doc(postId);
    if (isLike) {
      LikeUserModel likeUserModel = LikeUserModel(
        profilePhoto: userModel!.photo,
        userName: '${userModel!.firstName} ${userModel!.lastName}',
        like: isLike,
        userUid: userModel!.uid,
      );
      try {
        await postDocRef
            .collection(kLikesCollection)
            .doc(userModel!.uid)
            .set(likeUserModel.toJson());

        // Send Notification if liker is not the post owner
        if (postCreatorUid != userModel!.uid) {
          final notificationId =
              DateTime.now().millisecondsSinceEpoch.toString();
          final notification = NotificationModel(
            notificationId: notificationId,
            senderUid: userModel!.uid,
            receiverUid: postCreatorUid,
            senderName: '${userModel!.firstName} ${userModel!.lastName}',
            senderPhoto: userModel!.photo,
            type: 'like',
            content: 'liked your post',
            postId: postId,
            isRead: false,
            dateTime: DateTime.now(),
          );

          await _userCollectionRef
              .doc(postCreatorUid)
              .collection('notifications')
              .doc(notificationId)
              .set(notification.toMap());

          // Send Push Notification
          final postOwnerDoc =
              await _userCollectionRef.doc(postCreatorUid).get();
          if (postOwnerDoc.exists) {
            final postOwnerData = postOwnerDoc.data();
            if (postOwnerData != null) {
              final String? token = postOwnerData['fcmToken'];
              if (token != null && token.isNotEmpty) {
                await NotificationService().sendNotification(
                  receiverToken: token,
                  title: '${userModel!.firstName} ${userModel!.lastName}',
                  body: 'liked your post',
                  senderPhoto: userModel!.photo,
                );
              }
            }
          }
        }
      } catch (errMessage) {
        emit(LikePostFailureState(
            errMessage: 'Like error: ${errMessage.toString()}'));
      }
    } else {
      try {
        await postDocRef
            .collection(kLikesCollection)
            .doc(userModel!.uid)
            .delete();
        // Ideally we might want to remove the notification if unlike happens,
        // but typically we let it be or it complicates things unnecessarily.
      } catch (errMessage) {
        emit(LikePostFailureState(
            errMessage: 'Like error: ${errMessage.toString()}'));
      }
    }
    // Refresh likes collection and emit success state
    final likesCollection = await getPostLikes(postId);
    emit(ToggleLikeSuccessState());
    return likesCollection;
  }

  // Fetch a single post by ID (Helper for notifications)
  Future<PostModel?> getPostById(String postId) async {
    try {
      DocumentSnapshot doc = await _postCollectionRef.doc(postId).get();
      if (doc.exists) {
        return PostModel.fromJson(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      //  debugPrint("Error fetching post by ID: $e");
    }
    return null;
  }

  // Get all like documents for a given post
  Future<QuerySnapshot<Map<String, dynamic>>> getPostLikes(
      String postId) async {
    late QuerySnapshot<Map<String, dynamic>> postLikes;
    try {
      postLikes = await FirebaseFirestore.instance
          .collection(kPostsCollection)
          .doc(postId)
          .collection(kLikesCollection)
          .get();
      emit(GetPostLikesSuccessState());
    } on Exception catch (e) {
      emit(GetPostLikesFailureState(errMessage: e.toString()));
    }
    return postLikes;
  }

  // List of user models the current user is following
  List<UserModel> followings = [];
  late int numberOfFollowing;

  // Get the users the current user is following
  // Get the users the current user is following
  Future<QuerySnapshot<Map<String, dynamic>>> getFollowing() async {
    final followingSnapshot = await FirebaseFirestore.instance
        .collection(kUsersCollection)
        .doc(currentUserUid)
        .collection(kFollowingCollection)
        .get();

    // Use a temporary list to avoid duplicates/race conditions during async fetching
    List<UserModel> tempFollowings = [];
    numberOfFollowing = followingSnapshot.docs.length;

    for (var userDoc in followingSnapshot.docs) {
      final UserModel? userModel =
          await getUserData(userUid: userDoc.id, emitState: false);
      if (userModel != null) {
        tempFollowings.add(userModel);
      }
    }

    // Assign the full list at once
    followings = tempFollowings;
    emit(GetFollowingSuccessState());
    return followingSnapshot;
  }

  // List of user models following the current user
  List<UserModel> followers = [];
  late int numberOfFollowers;

  // Get the users following the current user
  Future<void> getFollowers() async {
    final followersSnapshot = await FirebaseFirestore.instance
        .collection(kUsersCollection)
        .doc(currentUserUid)
        .collection(kFollowersCollection)
        .get();
    followers.clear();
    numberOfFollowers = followersSnapshot.docs.length;
    for (var userDoc in followersSnapshot.docs) {
      final UserModel? userModel = await getUserData(userUid: userDoc.id);
      if (userModel != null) followers.add(userModel);
    }
    emit(GetFollowersSuccessState());
  }

  // Timeline post models and their Firestore IDs
  List<PostModel> friendsPostsModelList = [];
  List<String> friendsPostsIdList = [];

  // Fetch timeline posts (user + followings) and update lists
  Future<void> getTimelinePosts() async {
    emit(GetFeedsPostsLoadingState());

    try {
      // Step 1: Get the list of followings and their UIDs
      final followingSnapshot = await getFollowing();

      List<String> uids = followingSnapshot.docs.map((doc) => doc.id).toList();

      // Step 2: Add current user UID
      uids.add(currentUserUid);

      // Step 3: Query posts by all those UIDs
      final postsSnapshot = await FirebaseFirestore.instance
          .collection(kPostsCollection)
          .where('uid', whereIn: uids)
          .orderBy(kCreatedAt, descending: true)
          .get();

      // Step 4: Clear old timeline posts
      friendsPostsModelList.clear();
      friendsPostsIdList.clear();

      // Step 5: Deserialize all timeline posts
      for (var postDoc in postsSnapshot.docs) {
        if (!reportedPostsIds.contains(postDoc.id)) {
          friendsPostsModelList.add(PostModel.fromJson(postDoc.data()));
          friendsPostsIdList.add(postDoc.id);
        }
      }

      emit(GetFeedsPostsSuccessState());
    } catch (error) {
      emit(GetFeedsPostsFailureState(errMessage: error.toString()));
    }
  }

  // User's own post models and their Firestore IDs
  List<PostModel> myPostsModelList = [];
  List<String> myPostsIdList = [];

  // Fetch all posts by a specific user UID
  Future<void> getMyUserPosts(String uid) async {
    emit(GetMyPostsLoading());
    try {
      final postsSnapshot = await FirebaseFirestore.instance
          .collection(kPostsCollection)
          .where('uid', isEqualTo: uid)
          .orderBy(kCreatedAt, descending: true)
          .get();

      myPostsModelList.clear();
      myPostsIdList.clear();

      for (var postDoc in postsSnapshot.docs) {
        myPostsModelList.add(PostModel.fromJson(postDoc.data()));
        myPostsIdList.add(postDoc.id);
      }
      emit(GetMyPostsSuccess());
    } on Exception catch (e) {
      emit(GetMyPostsFailure(errMessage: e.toString()));
    }
  }

  // Log out the user and clear all cached user data
  Future<void> logOut() async {
    emit(LogOutLoadingState());
    try {
      await FirebaseAuth.instance.signOut();
      await CacheHelper.deleteCash(key: kUidToken);
      // Clear all local and model user data to prevent data bleed between sessions
      userModel = null;
      uidTokenCache = null;
      myPostsModelList.clear();
      myPostsIdList.clear();
      friendsPostsModelList.clear();
      friendsPostsIdList.clear();
      followers.clear();
      followings.clear();
      emit(LogOutSuccessState());
    } on Exception catch (e) {
      emit(LogOutFailureState(
          errMessage: 'error during logout :  ${e.toString()}'));
    }
  }

  // Function to permanently delete the user account and all associated data
  Future<void> deleteUserAccount() async {
    emit(DeleteAccountLoadingState());
    try {
      String uid = currentUserUid;
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) throw Exception("No user found");

      // 1. Delete profile photo and cover photo from Firebase Storage if they exist
      if (userModel?.photo != null) {
        try {
          await FirebaseStorage.instance.refFromURL(userModel!.photo!).delete();
        } catch (e) {
          emit(GetMyPostsFailure(
              errMessage: "Profile photo already deleted or not found"));
        }
      }
      if (userModel?.cover != null) {
        try {
          await FirebaseStorage.instance.refFromURL(userModel!.cover!).delete();
        } catch (e) {
          emit(GetMyPostsFailure(
              errMessage: "Cover photo already deleted or not found"));
        }
      }

      // 2. Delete all user's posts and their images from Storage and Firestore
      var userPosts =
          await _postCollectionRef.where('uid', isEqualTo: uid).get();
      for (var post in userPosts.docs) {
        // Delete post image from Storage if it exists
        if (post.data()['postImage'] != null) {
          try {
            await FirebaseStorage.instance
                .refFromURL(post.data()['postImage'])
                .delete();
          } catch (e) {
            emit(GetMyPostsFailure(
                errMessage: "Post image not found in storage"));
          }
        }
        // Delete the post document itself
        await post.reference.delete();
      }

      // 3. Delete all user's comments (and their images) from ALL posts, including others' posts
      var allPosts =
          await FirebaseFirestore.instance.collection(kPostsCollection).get();
      for (var postDoc in allPosts.docs) {
        var myComments = await postDoc.reference
            .collection(kCommentsCollection)
            .where('uid', isEqualTo: uid)
            .get();

        for (var comment in myComments.docs) {
          // Delete comment image from Storage if it exists
          if (comment.data()['image'] != null) {
            try {
              await FirebaseStorage.instance
                  .refFromURL(comment.data()['image'])
                  .delete();
            } catch (e) {
              emit(GetMyPostsFailure(
                  errMessage: "Comment image not found in storage"));
            }
          }
          // Delete the comment document itself
          await comment.reference.delete();
        }
      }

      // 4. Handle user chat conversations and delete from both sides
      var chatListSnapshot =
          await _userCollectionRef.doc(uid).collection(kChatCollection).get();

      for (var chatDoc in chatListSnapshot.docs) {
        String friendUid = chatDoc.id;

        // A. Delete messages and attached files (images/voice records) from Storage and Firestore for the friend
        var friendMessages = await _userCollectionRef
            .doc(friendUid)
            .collection(kChatCollection)
            .doc(uid)
            .collection(kMessageCollection)
            .get();

        for (var msg in friendMessages.docs) {
          // Delete images attached to the message, if any
          if (msg.data()['images'] != null) {
            for (var imgUrl in (msg.data()['images'] as List)) {
              try {
                await FirebaseStorage.instance.refFromURL(imgUrl).delete();
              } catch (e) {
                emit(GetMyPostsFailure(
                    errMessage: "Image not found in storage"));
              }
            }
          }
          // Delete voice record attached to the message, if any
          if (msg.data()['voiceRecord'] != null) {
            try {
              await FirebaseStorage.instance
                  .refFromURL(msg.data()['voiceRecord'])
                  .delete();
            } catch (e) {
              emit(GetMyPostsFailure(
                  errMessage: "Voice record not found in storage"));
            }
          }
          await msg.reference.delete();
        }

        // B. Delete chat preview from friend's chats
        await _userCollectionRef
            .doc(friendUid)
            .collection(kChatCollection)
            .doc(uid)
            .delete();

        // C. Delete messages and preview from user's own chats
        var myMessages =
            await chatDoc.reference.collection(kMessageCollection).get();
        for (var msg in myMessages.docs) {
          await msg.reference.delete();
        }
        await chatDoc.reference.delete();
      }

      // 5. Delete user's main document
      await _userCollectionRef.doc(uid).delete();

      // 6. Permanently delete user account from Firebase Authentication
      await user.delete();

      // Clear all local and model user data to prevent data bleed between sessions
      await CacheHelper.deleteCash(key: kUidToken);
      userModel = null;
      uidTokenCache = null;
      myPostsModelList.clear();
      myPostsIdList.clear();
      friendsPostsModelList.clear();
      friendsPostsIdList.clear();
      followers.clear();
      followings.clear();

      emit(DeleteAccountSuccessState());
    } on FirebaseAuthException catch (e) {
      // If the account deletion requires re-authentication, emit a helpful message
      if (e.code == 'requires-recent-login') {
        emit(DeleteAccountFailureState(
            errMessage:
                "For security reasons, please sign out and then sign in again before deleting your account."));
      } else {
        emit(DeleteAccountFailureState(errMessage: e.toString()));
      }
    } catch (e) {
      emit(DeleteAccountFailureState(errMessage: e.toString()));
    }
  }
}
