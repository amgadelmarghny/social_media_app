import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:social_media_app/shared/components/custom_time_ago.dart';
import '../../../models/comment_model.dart';
import '../../../models/user_model.dart';
import '../../../shared/bloc/comments_cubit/comments_cubit.dart';
import '../../../shared/components/comment_item.dart';
import '../../../shared/components/send_comment_button.dart';

class CommentsSheetBody extends StatelessWidget {
  const CommentsSheetBody(
      {super.key, required this.userModel, required this.postId});
  final UserModel userModel;
  final String postId;

  @override
  Widget build(BuildContext context) {
    CommentsCubit commentsCubit = BlocProvider.of<CommentsCubit>(context);
    return BlocBuilder<CommentsCubit, CommentsState>(builder: (context, state) {
      return Column(
        children: [
          Expanded(
            child: ConditionalBuilder(
                condition: commentsCubit.commentsModelList.isNotEmpty,
                builder: (context) => LiquidPullToRefresh(
                      showChildOpacityTransition: false,
                      backgroundColor: const Color(0xff8862D9),
                      springAnimationDurationInMilliseconds: 500,
                      animSpeedFactor: 1.8,
                      color: const Color(0xffC58DEB),
                      borderWidth: 3,
                      height: 100,
                      onRefresh: () async {
                        await BlocProvider.of<CommentsCubit>(context)
                            .getComments(postId: postId);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ListView.builder(
                          itemBuilder: (context, index) => CommentItem(
                            userName:
                                commentsCubit.commentsModelList[index].userName,
                            commentContent:
                                commentsCubit.commentsModelList[index].comment!,
                            dateTime: timeAgo(
                                commentsCubit.commentsModelList[index].dateTime),
                            profilePhoto: commentsCubit
                                .commentsModelList[index].profilePhoto,
                          ),
                          itemCount: commentsCubit.commentsModelList.length,
                        ),
                      ),
                    ),
                fallback: (context) => const SizedBox()),
          ),
          if (commentsCubit.pickedImage != null)
            // chosen image
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
            padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 15),
            child: SendCommentButton(
              onPressed: () async {
                final DateTime now = DateTime.now();
                final currentTime = DateTime(
                    now.year, now.month, now.day, now.hour, now.minute);
                if (commentsCubit.pickedImage != null) {
                  String? commentPhoto = await commentsCubit
                      .uploadImageToFirebase(commentsCubit.pickedImage!);
                  if (commentPhoto != null) {
                    CommentModel commentModel = CommentModel(
                      userName: '${userModel.firstName} ${userModel.lastName}',
                      comment: commentsCubit.commentController.text,
                      profilePhoto: userModel.photo,
                      commentPhoto: commentPhoto,
                      dateTime: currentTime,
                      userUid: userModel.uid,
                    );
                    if (!context.mounted) return;
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
                } else {
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
              },
            ),
          )
        ],
      );
    });
  }
}
