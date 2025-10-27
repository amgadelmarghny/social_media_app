import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/shared/bloc/comments_cubit/comments_cubit.dart';
import 'package:social_media_app/shared/components/show_toast.dart';
import 'package:social_media_app/shared/style/theme/theme.dart';
import 'comments_sheet_body.dart';

class CommentsSheet extends StatelessWidget {
  const CommentsSheet({
    super.key,
    required this.postId,
    required this.commentsNum,
    required this.creatorUid,
  });
  final String postId, creatorUid;
  final int commentsNum;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CommentsCubit()..getComments(postId: postId),
      child: Container(
        decoration: themeColor(),
        padding: const EdgeInsets.only(top: 40),
        child: Scaffold(
          appBar: AppBar(),
          body: BlocListener<CommentsCubit, CommentsState>(
            listener: (BuildContext context, CommentsState state) {
              if (state is PickCommentImageFailureState) {
                showToast(msg: state.errMessage, toastState: ToastState.error);
              }
              if (state is UploadCommentImageFailureState) {
                showToast(msg: state.errMessage, toastState: ToastState.error);
              }
              if (state is GetCommentsFailure) {
                showToast(msg: state.error, toastState: ToastState.error);
              }
              if (state is AddCommentFailure) {
                showToast(msg: state.error, toastState: ToastState.error);
              }
            },
            child: CommentsSheetBody(
              postId: postId,
              commentsNum: commentsNum,
              creatorUid: creatorUid,
            ),
          ),
        ),
      ),
    );
  }
}
