import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icon_broken/icon_broken.dart';
import 'package:image_picker/image_picker.dart';
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
  // Cached user UID token from local storage
  String? uidTokenCache;

  SocialCubit() : super(SocialInitial()) {
    _initializeUidToken();
  }

  void _initializeUidToken() {
    uidTokenCache = CacheHelper.getData(key: kUidToken);
  }

  // Get the current user UID with fallback to Firebase Auth
  String get currentUserUid =>
      uidTokenCache ?? FirebaseAuth.instance.currentUser!.uid;

  // Current index for bottom navigation bar
  int currentBottomNavBarIndex = 0;

  /// Change the current index of the bottom navigation bar
  void changeBottomNavBar(int value) {
    currentBottomNavBarIndex = value;
    emit(BottomNavBarState());
  }

  // List of widgets for each tab in the bottom navigation bar
  final List<Widget> currentBody = const [
    FeedsBody(),
    ChatsBody(),
    CreatePostSheet(),
    UsersBody(),
    NotificationsBody(),
  ];

  // List of items for the bottom navigation bar
  final List<BottomNavigationBarItem> bottomNavigationBarItem = const [
    BottomNavigationBarItem(icon: Icon(IconBroken.Home), label: ''),
    BottomNavigationBarItem(
        icon: Padding(
            padding: EdgeInsets.only(right: 10), child: Icon(IconBroken.Chat)),
        label: ''),
    BottomNavigationBarItem(
        icon: SizedBox(
          width: 35,
        ),
        label: ''),
    BottomNavigationBarItem(icon: Icon(IconBroken.Profile), label: ''),
    BottomNavigationBarItem(icon: Icon(IconBroken.Notification), label: ''),
  ];

  // User model for the currently logged-in user
  UserModel? userModel;

  // Firestore references for posts and users collections
  final _postCollectionRef =
      FirebaseFirestore.instance.collection(kPostsCollection);
  final _userCollectionRef =
      FirebaseFirestore.instance.collection(kUsersCollection);

  /// Fetch user data from Firestore and update [userModel]
  Future<UserModel> getUserData({required String userUid}) async {
    emit(GetMyDataLoadingState());
    try {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await _userCollectionRef.doc(userUid).get();
      UserModel spacificUserModel =
          UserModel.fromJson(documentSnapshot.data()!);
      //if the userModel != null that means getUserData used to featch friends data
      userModel ??= spacificUserModel;

      emit(GetMyDataSuccessState());
      return spacificUserModel;
    } catch (error) {
      emit(GetMyDataFailureState(errMessage: error.toString()));
      rethrow;
    }
  }

  // Controllers for editing user profile fields
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController birthdayController = TextEditingController();
  String? updatedYear;
  String? updatedDayAndMonth;

  /// Update user information in Firestore
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

  /// Pick an image from the gallery and return a [File]
  Future<File?> pickImage() async {
    emit(PickImageLoadingState());

    final ImagePicker picker = ImagePicker();
    XFile? returnImage = await picker.pickImage(source: ImageSource.gallery);

    if (returnImage != null) {
      emit(PickImageSuccessState());
      return File(returnImage.path);
    } else {
      emit(PickImageFailureState(errMessage: 'No image selected'));
      return null;
    }
  }

  /// Upload a profile image to Firebase Storage and return its URL
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

  /// Pick and upload a profile image, then update the user's profile photo
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

  /// Upload a cover image to Firebase Storage and return its URL
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

  /// Pick and upload a cover image, then update the user's cover photo
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

  /// Upload a post image to Firebase Storage and return its URL
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

  /// Create a new post in Firestore
  Future<void> _createPost(CreatePostImplModel createPostImplModel) async {
    emit(CreatePostLoadingState());
    PostModel postModel = PostModel(
      userName: '${userModel!.firstName} ${userModel!.lastName}',
      uid: userModel!.uid,
      profilePhoto: userModel!.photo,
      dateTime: createPostImplModel.dateTime,
      content: createPostImplModel.content,
      postImage: createPostImplModel.postImage,
    );
    try {
      await _postCollectionRef.add(postModel.toJson());
      postContentController.clear();
      postImagePicked = null;
      emit(CreatePostSuccessState());

      // Refresh posts after successfully adding a new post
      getMyUserPosts(userModel!.uid);
      await getTimelinePosts();
    } catch (err) {
      emit(CreatePostFailureState(errMessage: err.toString()));
    }
  }

  // File for the picked post image
  File? postImagePicked;
  // Controller for the post content text field
  TextEditingController postContentController = TextEditingController();

  /// Create a post with a photo (and optional content)
  Future<void> createPostWithPhoto(
      {required String? postContent, required DateTime dateTime}) async {
    if (postImagePicked != null) {
      String? postUrl = await _uploadPostImage(file: postImagePicked!);
      if (postUrl != null) {
        CreatePostImplModel createPostImplModel = CreatePostImplModel(
          content: postContent,
          postImage: postUrl,
          dateTime: dateTime,
        );
        await _createPost(createPostImplModel);
      }
    }
  }

  /// Remove the picked post image file
  void removePickedFile() {
    postImagePicked = null;
    emit(RemovePickedFile());
  }

  /// Create a post with only content (no image)
  Future<void> createPostWithContentOnly(
      {required String? postContent, required DateTime dateTime}) async {
    CreatePostImplModel createPostImplModel = CreatePostImplModel(
      content: postContent,
      postImage: null,
      dateTime: dateTime,
    );
    await _createPost(createPostImplModel);
  }

  /// Remove the post image and clear the post content
  void cancelPostDuringCreating() {
    postImagePicked = null;
    postContentController.text = '';
    emit(RemovePostState());
  }

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

  //!
  Future<List<String>> _getUsersLikesUidInPost({required String postId}) async {
    List<String> usersLikesUid = [];
    // Access the document(post) from Firestore
    DocumentReference postDocRef = _postCollectionRef.doc(postId);
    var likeCollectionInThePostCollection =
        await postDocRef.collection(kLikesCollection).get();
    var usersLikesUidDocs = likeCollectionInThePostCollection.docs;
    for (var usersUid in usersLikesUidDocs) {
      usersLikesUid.add(usersUid.id);
    }
    return usersLikesUid;
  }

  List<UserModel> userModelList = [];
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

  /// Toggle like/unlike for a post.
  /// If [isLike] is true, add a like; otherwise, remove the like.
  Future<QuerySnapshot<Map<String, dynamic>>> toggleLike(
      {required String postId, required bool isLike}) async {
    emit(ToggleLikeLoadingState());
    // Access the document(post) from Firestore
    DocumentReference postDocRef = _postCollectionRef.doc(postId);
    // If the user likes the post, add the user's like model
    // to the likes collection in the user's UID doc
    if (isLike) {
      LikeUserModel likeUserModel = LikeUserModel(
        profilePhoto: userModel!.photo,
        userName: '${userModel!.firstName} ${userModel!.lastName}',
        like: isLike,
        // NOTE: This should be a String UID, not FirebaseAuth.instance
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
    }
    // If the user unlikes the post, delete the user's like from the collection
    else {
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
    // Get the updated likes collection for the post
    final likesCollection = await getPostLikes(postId);
    emit(ToggleLikeSuccessState());
    return likesCollection;
  }

  // Get all likes for a given post
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

  List<UserModel> followings = [];
  late int numberOfFollowing;

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

  List<UserModel> followers = [];
  late int numberOfFollowers;

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

  // List of all posts fetched from Firestore
  List<PostModel> freindsPostsModelList = [];
  // List of post IDs
  List<String> freindsPostsIdList = [];

  /// Fetch all posts from Firestore and update [freindsPostsModelList] and [freindsPostsIdList]
  Future<void> getTimelinePosts() async {
    emit(GetFeedsPostsLoadingState());

    //try {
    // 1. هات الناس اللي متابعهم
    final followingSnapshot = await getFollowing();
    // 2. كون ليست من UIDs
    List<String> uids = followingSnapshot.docs.map((doc) => doc.id).toList();

    // ضيف الـ uid بتاع اليوزر نفسه
    uids.add(currentUserUid);

    // 3. هات البوستات
    final postsSnapshot = await FirebaseFirestore.instance
        .collection(kPostsCollection)
        .where('uid', whereIn: uids)
        .orderBy(kCreatedAt, descending: true)
        .get();

    freindsPostsModelList.clear();
    freindsPostsIdList.clear();

    for (var postDoc in postsSnapshot.docs) {
      freindsPostsModelList.add(PostModel.fromJson(postDoc.data()));
      freindsPostsIdList.add(postDoc.id);
    }
    emit(GetFeedsPostsSuccessState());
    // } catch (error) {
    //   emit(GetFeedsPostsFailureState(errMessage: error.toString()));
    // }
  }

  // List of all posts fetched from Firestore
  List<PostModel> postsModelList = [];
  // List of post IDs
  List<String> postsIdList = [];

  Future<void> getMyUserPosts(String uid) async {
    emit(GetMyPostsLoading());
    try {
      final postsSnapshot = await FirebaseFirestore.instance
          .collection(kPostsCollection)
          .where('uid', isEqualTo: uid)
          .orderBy(kCreatedAt, descending: true)
          .get();

      postsModelList.clear();
      postsIdList.clear();

      for (var postDoc in postsSnapshot.docs) {
        postsModelList.add(PostModel.fromJson(postDoc.data()));
        postsIdList.add(postDoc.id);
        emit(GetMyPostsSuccess());
      }
    } on Exception catch (e) {
      emit(GetMyPostsFailure(errMessage: e.toString()));
    }
  }

  Future<void> logOut() async {
    emit(LogOutLoadingState());
    try {
      await FirebaseAuth.instance.signOut();
      await CacheHelper.deleteCash(key: kUidToken);
      emit(LogOutSuccessState());
    } on Exception catch (e) {
      emit(LogOutFailureState(errMessage: e.toString()));
    }
  }
}
