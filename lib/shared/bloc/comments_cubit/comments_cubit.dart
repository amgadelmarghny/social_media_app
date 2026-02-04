import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:social_media_app/models/comment_model.dart';
import 'package:social_media_app/shared/components/constants.dart';
import 'package:social_media_app/models/notification_model.dart';

import 'package:social_media_app/shared/services/notification_service.dart';
part 'comments_state.dart';

class CommentsCubit extends Cubit<CommentsState> {
  CommentsCubit() : super(CommentsInitial());

  // pike Image
  File? pickedImage;

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
    emit(PickCommentImageFailureState(
        errMessage: "Gallery access permission denied"));
    return null;
  }

  // Helper function to open device gallery and allow user to pick an image
  Future<File?> _openGallery() async {
    emit(PickCommentImageLoadingState());
    final ImagePicker picker = ImagePicker();
    final XFile? selectedImage =
        await picker.pickImage(source: ImageSource.gallery);

    if (selectedImage != null) {
      emit(PickCommentImageSuccessState());
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

  ////? add comment
  User currentUser = FirebaseAuth.instance.currentUser!;

  TextEditingController commentController = TextEditingController();

  Future<void> addComment(
      {required String postId,
      required CommentModel commentModel,
      required String postUid}) async {
    emit(AddCommentLoading());
    try {
      await FirebaseFirestore.instance
          .collection(kPostsCollection)
          .doc(postId)
          .collection(kCommentsCollection)
          .add(commentModel.toMap());

      // Send Notification if commenter is not the post owner
      if (postUid != currentUser.uid) {
        final notificationId = DateTime.now().millisecondsSinceEpoch.toString();
        final notification = NotificationModel(
          notificationId: notificationId,
          senderUid: currentUser.uid,
          receiverUid: postUid,
          senderName: commentModel.userName,
          senderPhoto: commentModel.profilePhoto,
          type: 'comment',
          content: 'commented: ${commentModel.comment ?? "Sent an image"}',
          postId: postId,
          isRead: false,
          dateTime: DateTime.now(),
        );

        await FirebaseFirestore.instance
            .collection(kUsersCollection)
            .doc(postUid)
            .collection('notifications')
            .doc(notificationId)
            .set(notification.toMap());

        // Send Push Notification
        final postOwnerDoc = await FirebaseFirestore.instance
            .collection(kUsersCollection)
            .doc(postUid)
            .get();
        if (postOwnerDoc.exists) {
          final postOwnerData = postOwnerDoc.data();
          if (postOwnerData != null) {
            final String? token = postOwnerData['fcmToken'];
            if (token != null && token.isNotEmpty) {
              await NotificationService().sendNotification(
                receiverToken: token,
                title: commentModel.userName,
                body: 'commented: ${commentModel.comment ?? "Sent an image"}',
                senderPhoto: commentModel.profilePhoto,
              );
            }
          }
        }
      }

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
