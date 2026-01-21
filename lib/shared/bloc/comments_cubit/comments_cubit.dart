import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:social_media_app/models/comment_model.dart';
import 'package:social_media_app/shared/components/constants.dart';
part 'comments_state.dart';

class CommentsCubit extends Cubit<CommentsState> {
  CommentsCubit() : super(CommentsInitial());

  // pike Image
  File? pickedImage;

  /// Picks an image from the gallery and returns a [File] to be used in the app.
  /// Handles required permissions for Android 12 and above, or Android 13 and above.
  Future<File?> pickPhoto() async {
    PermissionStatus status;

    // Check Android version to request proper permission.
    if (Platform.isAndroid && (await _getAndroidVersion()) >= 13) {
      // Android 13 and above uses the [photos] permission
      status = await Permission.photos.request();
    } else {
      // Android 12 and below uses the [storage] permission
      status = await Permission.storage.request();
    }

    // Check the result of the permission request.
    if (status.isGranted) {
      // Permission granted -> start picking image.
      emit(PickCommentImageLoadingState());

      final ImagePicker picker = ImagePicker();
      XFile? selectedImage =
          await picker.pickImage(source: ImageSource.gallery);

      if (selectedImage != null) {
        // User selected an image successfully.
        emit(PickCommentImageSuccessState());
        return File(selectedImage.path);
      } else {
        // User cancelled image picking or no image was selected.
        emit(PickCommentImageFailureState(errMessage: 'No image selected'));
        return null;
      }
      // ...other processing code can go here.
    } else if (status.isPermanentlyDenied) {
      // User permanently denied permission -> direct to app settings.
      openAppSettings();
    }
    return null;
  }

  /// Helper function to get the Android OS version as an integer.
  /// Returns the major version. If not Android, returns 0.
  Future<int> _getAndroidVersion() async {
    if (Platform.isAndroid) {
      // Parse the version string to retrieve the SDK major version.
      return int.parse(Platform.version.split(' ')[0].split('.')[0]);
      // Note: For more accuracy, consider using device_info_plus to get the exact SDK version.
    }
    return 0;
  }

  ////? add comment
  User currentUser = FirebaseAuth.instance.currentUser!;

  TextEditingController commentController = TextEditingController();

  Future<void> addComment(
      {required String postId, required CommentModel commentModel}) async {
    emit(AddCommentLoading());
    try {
      await FirebaseFirestore.instance
          .collection(kPostsCollection)
          .doc(postId)
          .collection(kCommentsCollection)
          .add(commentModel.toMap());
      emit(AddCommentSuccess());
      await getComments(postId: postId);
    } catch (err) {
      emit(AddCommentFailure(error: err.toString()));
    }
  }

  Future<String?> uploadImageToFirebase(File file) async {
    String? image;
    emit(UploadCommentImageLoadingState());
    try {
      final uploadedPic = await FirebaseStorage.instance
          .ref()
          .child(
              '$kUsersCollection/$kCommentFolder/${Uri.file(file.path).pathSegments.last}')
          .putFile(file);
      image = await uploadedPic.ref.getDownloadURL();
    } catch (err) {
      emit(UploadCommentImageFailureState(errMessage: err.toString()));
    }
    return image;
  }

  // get comments
  List<CommentModel> commentsModelList = [];
  List<String> commentIdList = [];
  Future<void> getComments({required String? postId}) async {
    emit(GetCommentsLoading());
    try {
      final commentsCollection = await FirebaseFirestore.instance
          .collection(kPostsCollection)
          .doc(postId)
          .collection(kCommentsCollection)
          .orderBy(kCreatedAt, descending: true)
          .get();
      commentsModelList.clear();
      for (var comment in commentsCollection.docs) {
        commentIdList.add(comment.id);

        commentsModelList.add(CommentModel.fromJson(comment.data()));
      }
      emit(GetCommentsSuccess());
    } catch (err) {
      if (!isClosed) {
        emit(GetCommentsFailure(error: err.toString()));
      }
    }
  }

  void removeImage() {
    pickedImage = null;
    emit(RemoveCommentPicture());
  }
}
