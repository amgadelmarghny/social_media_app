import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/shared/bloc/comments_cubit/comments_cubit.dart';
import 'package:social_media_app/shared/components/show_toast.dart';
import 'package:social_media_app/shared/style/theme/theme.dart';
import '../../../models/user_model.dart';
import 'comments_sheet_body.dart';

class CommentsSheet extends StatelessWidget {
  const CommentsSheet(
      {super.key, required this.postId, required this.userModel});
  final String postId;
  final UserModel userModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: themeColor(),
      padding: const EdgeInsets.only(top: 40),
      child: Scaffold(
        appBar: AppBar(),
        body: BlocListener<CommentsCubit, CommentsState>(
          listener: (BuildContext context, CommentsState state) {
            if (state is PickImageFailureState) {
              showToast(msg: state.errMessage, toastState: ToastState.error);
            }
            if (state is UploadCommentImageFailureState) {
              showToast(msg: state.errMessage, toastState: ToastState.error);
            }
            if (state is AddCommentFailure) {
              showToast(msg: state.error, toastState: ToastState.error);
            }
          },
          child: CommentsSheetBody(
            userModel: userModel,
            postId: postId,
          ),
        ),
      ),
    );
  }
}
