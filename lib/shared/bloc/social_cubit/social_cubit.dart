import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:icon_broken/icon_broken.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media_app/models/create_post_impl_model.dart';
import 'package:social_media_app/models/post_model.dart';
import 'package:social_media_app/models/user_model.dart';
import 'package:social_media_app/modules/chat/chat_body.dart';
import 'package:social_media_app/modules/feeds/feeds_body.dart';
import 'package:social_media_app/modules/new_post/new_post.dart';
import 'package:social_media_app/modules/notifications/notifications_body.dart';
import 'package:social_media_app/modules/users/users_body.dart';
import 'package:social_media_app/shared/components/constants.dart';
import 'package:social_media_app/shared/network/local/cache_helper.dart';
import '../../../models/like_model.dart';
import '../../../models/update_user_impl_model.dart';
part 'social_state.dart';

class SocialCubit extends Cubit<SocialState> {
  SocialCubit() : super(SocialInitial());

  // Cached user UID token from local storage
  String uidTokenCache = CacheHelper.getData(key: kUidToken);

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
    ChatBody(),
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
  Future<void> getUserData() async {
    emit(GetUserDataLoadingState());
    try {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await FirebaseFirestore.instance
              .collection(kUsersCollection)
              .doc(uidTokenCache)
              .get();
      userModel = UserModel.fromJson(documentSnapshot.data()!);
      emit(GetUserDataSuccessState());
    } catch (error) {
      emit(GetUserDataFailureState(errMessage: error.toString()));
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
          .doc(uidTokenCache)
          .update(updateUserImplModel.toMap(userModel!));
      await getUserData();
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
      emit(CreatePostSuccessState());
      // Refresh posts after successfully adding a new post
      await getPosts();
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
  void removePost() {
    postImagePicked = null;
    postContentController.text = '';
    emit(RemovePostState());
  }

  // List of all posts fetched from Firestore
  List<PostModel> postsModelList = [];
  // List of post IDs
  List<String> postsIdList = [];
  // List<int> numbersOfLikesInPostsList = [];

  /// Fetch all posts from Firestore and update [postsModelList] and [postsIdList]
  Future<void> getPosts() async {
    emit(GetPostsLoadingState());
    try {
      var postsDocumentSnapshot =
          await _postCollectionRef.orderBy(kDateTime, descending: true).get();

      postsIdList.clear();
      // numbersOfLikesInPostsList.clear();
      postsModelList.clear();
      for (var postDocInCollection in postsDocumentSnapshot.docs) {
        // int numberOfLikeInPost =
        //     // to get post's like number
        //     await _getLikesInPostDocument(postDocInCollection);
        // // put likes of every post in the list
        // numbersOfLikesInPostsList.add(numberOfLikeInPost);
        // Add post ID to the list
        postsIdList.add(postDocInCollection.id);
        // Add post data to the list
        postsModelList.add(PostModel.fromJson(postDocInCollection.data()));
      }
      emit(GetPostsSuccessState());
    } catch (error) {
      emit(GetPostsFailureState(errMessage: error.toString()));
    }
  }

  // Future<int> _getLikesInPostDocument(
  //     QueryDocumentSnapshot<Map<String, dynamic>>
  //         postDocumentInCollection) async {
  //   var likeCollectionInThePostCollection = await postDocumentInCollection
  //       .reference
  //       .collection(kLikesCollection)
  //       .get();
  //   int numbersOfLikes = likeCollectionInThePostCollection.docs.length;
  //   return numbersOfLikes;
  // }

  /// Toggle like/unlike for a post.
  /// If [isLike] is true, add a like; otherwise, remove the like.
  Future<QuerySnapshot<Map<String, dynamic>>> toggleLike(
      {required String postId, required bool isLike}) async {
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

  /// Get all likes for a given post
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
}
