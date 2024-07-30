import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/models/user_model.dart';
import '../../../shared/style/fonts/font_style.dart';
import '../../../shared/style/theme/constant.dart';
import '../../models/comment_model.dart';
import '../bloc/comments_cubit/comments_cubit.dart';

class SendCommentButton extends StatelessWidget {
  const SendCommentButton(
      {super.key, required this.userModel, required this.postId});
  final UserModel userModel;
  final String postId;

  @override
  Widget build(BuildContext context) {
    CommentsCubit commentsCubit = BlocProvider.of<CommentsCubit>(context);

    return TextField(
      style: FontsStyle.font18Popin(isShadow: true),
      controller: commentsCubit.commentController,
      decoration: InputDecoration(
        hintStyle: FontsStyle.font18Popin(isShadow: true),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: IconButton(
            onPressed: () async {
              commentsCubit.pickedImage = await commentsCubit.pickPhoto();
            },
            icon: const Icon(
              Icons.photo_outlined,
            ),
          ),
        ),
        prefixIconColor: defaultColor,
        suffixIconColor: defaultColor,
        suffixIcon: BlocBuilder<CommentsCubit, CommentsState>(
          builder: (context, state) {
            return IconButton(
              onPressed: () async {
                await _sendCommentMethod(
                  commentsCubit: commentsCubit,
                  userModel: userModel,
                  postId: postId,
                );
              },
              icon: state is AddCommentLoading ||
                      state is UploadCommentImageLoadingState ||
                      state is GetCommentsLoading
                  ? const CircleAvatar(
                      radius: 10,
                      child: CircularProgressIndicator(
                        color: defaultColor,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Icon(Icons.send_outlined),
            );
          },
        ),
        hintText: 'Write a comment...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }

  Future<void> _sendCommentMethod(
      {required CommentsCubit commentsCubit,
      required UserModel userModel,
      required String postId}) async {
    final DateTime now = DateTime.now();
    final currentTime =
        DateTime(now.year, now.month, now.day, now.hour, now.minute);
    if (commentsCubit.pickedImage != null) {
      String? commentPhoto =
          await commentsCubit.uploadImageToFirebase(commentsCubit.pickedImage!);
      if (commentPhoto != null) {
        CommentModel commentModel = CommentModel(
          userName: '${userModel.firstName} ${userModel.lastName}',
          comment: commentsCubit.commentController.text,
          profilePhoto: userModel.photo,
          commentPhoto: commentPhoto,
          dateTime: currentTime,
          userUid: userModel.uid,
        );
        await commentsCubit
            .addComment(
          postId: postId,
          commentModel: commentModel,
        )
            .then((value) {
          // remove comment after add comment successfully
          commentsCubit.commentController.clear();
          commentsCubit.removeImage();
        });
      }
    } else if (commentsCubit.commentController.text.isNotEmpty) {
      CommentModel commentModel = CommentModel(
        userName: '${userModel.firstName} ${userModel.lastName}',
        comment: commentsCubit.commentController.text,
        profilePhoto: userModel.photo,
        commentPhoto: null,
        dateTime: currentTime,
        userUid: userModel.uid,
      );
      commentsCubit
          .addComment(
        postId: postId,
        commentModel: commentModel,
      )
          .then(
        (value) {
          // remove comment after add comment successfully
          commentsCubit.commentController.clear();
          commentsCubit.removeImage();
        },
      );
    }
  }
}
