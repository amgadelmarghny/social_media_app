import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/models/comment_model.dart';
import 'package:social_media_app/shared/components/constants.dart';
part 'comments_state.dart';

class CommentsCubit extends Cubit<CommentsState> {
  CommentsCubit() : super(CommentsInitial());

  User currentUser = FirebaseAuth.instance.currentUser!;

  void addComment(
      {required String postUid, required CommentModel commentModel}) {
    emit(AddCommentLoading());
    try {
      FirebaseFirestore.instance
          .collection(kPostsCollection)
          .doc(postUid)
          .collection(kCommentsCollection)
          .doc(currentUser.uid)
          .set(commentModel.toMap());
      emit(AddCommentSuccess());
    } catch (err) {
      emit(AddCommentFailure(error: err.toString()));
    }
  }

  int numberOfComment = 0;
  List<CommentModel> commentsModelList = [];
  void getComments({required String postUid}) async {
    emit(GetCommentsLoading());
    try {
      final commentsCollection = await FirebaseFirestore.instance
          .collection(kPostsCollection)
          .doc(postUid)
          .collection(kCommentsCollection)
          .get();
      numberOfComment = commentsCollection.docs.length;
      commentsModelList.clear();
      for (var comment in commentsCollection.docs) {
        commentsModelList.add(CommentModel.fromJson(comment.data()));
      }
      emit(GetCommentsSuccess());
    } catch (err) {
      emit(GetCommentsFailure(error: err.toString()));
    }
  }
}
