import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icon_broken/icon_broken.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:social_media_app/models/create_post_impl_model.dart';
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
part 'social_state.dart';

class SocialCubit extends Cubit<SocialState> {
  // Cached UID token for the logged-in user from local storage
  String? uidTokenCache;

  SocialCubit() : super(SocialInitial()) {
    _initializeUidToken();
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
    currentBottomNavBarIndex = value;
    emit(BottomNavBarState());
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
  final List<BottomNavigationBarItem> bottomNavigationBarItem = const [
    BottomNavigationBarItem(icon: Icon(IconBroken.Home), label: ''),
    BottomNavigationBarItem(
        icon: Padding(
          padding: EdgeInsets.only(right: 10),
          child: Icon(IconBroken.Chat),
        ),
        label: ''),
    BottomNavigationBarItem(
        icon: SizedBox(
          width: 35,
        ),
        label: ''),
    BottomNavigationBarItem(icon: Icon(IconBroken.Profile), label: ''),
    BottomNavigationBarItem(icon: Icon(IconBroken.Notification), label: ''),
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
  Future<UserModel> getUserData({required String userUid}) async {
    emit(GetMyDataLoadingState());
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await _userCollectionRef.doc(userUid).get();
    Map<String, dynamic> userModelData = documentSnapshot.data()!;
    UserModel spacificUserModel = UserModel.fromJson(userModelData);
    // Only update userModel if it's the first time or the current user's data is required
    if (userModel == null || userModel!.uid == userUid) {
      userModel = spacificUserModel;
    }
    emit(GetMyDataSuccessState());
    return spacificUserModel;
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
  Future<List<UserModel>?> searchUsers(String query) async {
    emit(SearchUsersLoadingState());
    if (query.trim().isEmpty) return [];

    final q = query.toLowerCase();
    final List<UserModel> usersList;
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(kUsersCollection)
          .orderBy('userName')
          .startAt([q])
          .endAt(['$q\uf8ff'])
          .limit(20)
          .get();

      usersList =
          snapshot.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
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
      await _postCollectionRef.add(postModel.toJson());
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
        userModelList.add(await getUserData(userUid: userUid));
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
      {required String postId, required bool isLike}) async {
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
  Future<QuerySnapshot<Map<String, dynamic>>> getFollowing() async {
    final followingSnapshot = await FirebaseFirestore.instance
        .collection(kUsersCollection)
        .doc(currentUserUid)
        .collection(kFollowingCollection)
        .get();
    followings.clear();
    numberOfFollowing = followingSnapshot.docs.length;
    for (var userDoc in followingSnapshot.docs) {
      final userModel = await getUserData(userUid: userDoc.id);
      followings.add(userModel);
    }
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
      final userModel = await getUserData(userUid: userDoc.id);
      followers.add(userModel);
    }
    emit(GetFollowersSuccessState());
  }

  // Timeline post models and their Firestore IDs
  List<PostModel> freindsPostsModelList = [];
  List<String> freindsPostsIdList = [];

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
      freindsPostsModelList.clear();
      freindsPostsIdList.clear();

      // Step 5: Deserialize all timeline posts
      for (var postDoc in postsSnapshot.docs) {
        freindsPostsModelList.add(PostModel.fromJson(postDoc.data()));
        freindsPostsIdList.add(postDoc.id);
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
      freindsPostsModelList.clear();
      freindsPostsIdList.clear();
      followers.clear();
      followings.clear();
      emit(LogOutSuccessState());
    } on Exception catch (e) {
      emit(LogOutFailureState(errMessage:'error during logout :  ${e.toString()}'));
    }
  }
}
