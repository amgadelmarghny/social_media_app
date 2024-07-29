import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/comment_model.dart';
import '../../../models/user_model.dart';
import '../../../shared/bloc/comments_cubit/comments_cubit.dart';
import '../../../shared/components/comment_item.dart';
import '../../../shared/style/fonts/font_style.dart';
import '../../../shared/style/theme/constant.dart';

class CommentsSheetBody extends StatelessWidget {
  const CommentsSheetBody(
      {super.key, required this.userModel, required this.postId});
  final UserModel userModel;
  final String postId;

  @override
  Widget build(BuildContext context) {
    CommentsCubit commentsCubit = BlocProvider.of<CommentsCubit>(context);
    return BlocBuilder<CommentsCubit, CommentsState>(builder: (context, state) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) => const CommentItem(),
                itemCount: 20,
              ),
            ),
            if (commentsCubit.pickedImage != null)
              Column(
                children: [
                  const Divider(
                    thickness: 2,
                    color: Colors.grey,
                    height: 8,
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Image.file(
                            commentsCubit.pickedImage!,
                            height: 90,
                          ),
                          InkWell(
                            onTap: () {
                              commentsCubit.removeImage();
                            },
                            child: const Icon(Icons.cancel_outlined),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: TextField(
                style: FontsStyle.font18Popin(
                  isShadow: true,
                  color: Colors.grey[300]!,
                ),
                controller: commentsCubit.commentController,
                decoration: InputDecoration(
                  hintStyle: FontsStyle.font18Popin(
                    isShadow: true,
                    color: Colors.grey[400]!,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: IconButton(
                      onPressed: () async {
                        commentsCubit.pickedImage =
                            await BlocProvider.of<CommentsCubit>(context)
                                .pickPhoto();
                      },
                      icon: const Icon(
                        Icons.photo_outlined,
                      ),
                    ),
                  ),
                  prefixIconColor: defaultColor,
                  suffixIconColor: defaultColor,
                  suffixIcon: IconButton(
                    onPressed: () async {
                      final DateTime now = DateTime.now();
                      final currentTime = DateTime(
                          now.year, now.month, now.day, now.hour, now.minute);
                      if (commentsCubit.pickedImage != null) {
                        String? commentPhoto = await commentsCubit
                            .uploadImageToFirebase(commentsCubit.pickedImage!);
                        if (commentPhoto != null) {
                          CommentModel commentModel = CommentModel(
                            userName:
                                '${userModel.firstName} ${userModel.lastName}',
                            comment: commentsCubit.commentController.text,
                            profilePhoto: userModel.photo,
                            commentPhoto: commentPhoto,
                            dateTime: currentTime,
                            userUid: userModel.uid,
                          );
                          if (!context.mounted) return;
                          await BlocProvider.of<CommentsCubit>(context)
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
                      } else {
                        CommentModel commentModel = CommentModel(
                          userName:
                              '${userModel.firstName} ${userModel.lastName}',
                          comment: commentsCubit.commentController.text,
                          profilePhoto: userModel.photo,
                          commentPhoto: null,
                          dateTime: currentTime,
                          userUid: userModel.uid,
                        );
                        BlocProvider.of<CommentsCubit>(context)
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
                  ),
                  hintText: 'Write a comment...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            )
          ],
        ),
      );
    });
  }
}
