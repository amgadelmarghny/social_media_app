import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media_app/models/comment_model.dart';
import 'package:social_media_app/shared/components/constants.dart';
part 'comments_state.dart';

class CommentsCubit extends Cubit<CommentsState> {
  CommentsCubit() : super(CommentsInitial());

  // pike Image
  File? pickedImage;
  Future<File?> pickPhoto() async {
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
  int numberOfComment = 0;
  List<CommentModel> commentsModelList = [];
  List<String> commentIdList = [];
  Future<void> getComments({required String? postId}) async {
    emit(GetCommentsLoading());
    try {
      final commentsCollection = await FirebaseFirestore.instance
          .collection(kPostsCollection)
          .doc(postId)
          .collection(kCommentsCollection)
          .orderBy(kDateTime, descending: true)
          .get();
      numberOfComment = commentsCollection.docs.length;
      print('numberOfCommenttttttt :: $numberOfComment');
      commentsModelList.clear();
      for (var comment in commentsCollection.docs) {
        commentIdList.add(comment.id);
        
        commentsModelList.add(CommentModel.fromJson(comment.data()));
      }
      emit(GetCommentsSuccess());
    } catch (err) {
      emit(GetCommentsFailure(error: err.toString()));
    }
  }

  void removeImage() {
    pickedImage = null;
    emit(RemoveCommentPicture());
  }
}
