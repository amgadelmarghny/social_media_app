import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/models/user_model.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import '../../../shared/style/fonts/font_style.dart';
import '../../../shared/style/theme/constant.dart';
import '../../models/comment_model.dart';
import '../bloc/comments_cubit/comments_cubit.dart';

/// A widget that provides a text field for writing and sending comments,
/// including the ability to attach an image.
class SendCommentButton extends StatelessWidget {
  const SendCommentButton({super.key, required this.postId});

  final String postId;

  @override
  Widget build(BuildContext context) {
    // Obtain the CommentsCubit from the context
    CommentsCubit commentsCubit = BlocProvider.of<CommentsCubit>(context);

    return TextField(
      style: FontsStyle.font18Popin(isShadow: true),
      controller: commentsCubit.commentController,
      decoration: InputDecoration(
        hintStyle: FontsStyle.font18Popin(isShadow: true),
        // Prefix icon for picking an image to attach to the comment
        prefixIcon: BlocBuilder<CommentsCubit, CommentsState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.only(left: 4),
              child: AbsorbPointer(
                absorbing: state is PickCommentImageLoadingState,
                child: IconButton(
                  onPressed: () async {
                    // Open image picker and set the picked image in the cubit
                    commentsCubit.pickedImage = await commentsCubit.pickPhoto();
                  },
                  icon: const Icon(
                    Icons.photo_outlined,
                  ),
                ),
              ),
            );
          },
        ),
        prefixIconColor: defaultTextColor,
        suffixIconColor: defaultTextColor,
        // Suffix icon for sending the comment
        suffixIcon: BlocBuilder<CommentsCubit, CommentsState>(
          builder: (context, state) {
            return IconButton(
              onPressed: () async {
                UserModel myUserModel =
                    BlocProvider.of<SocialCubit>(context).userModel!;
                // Send the comment when the send button is pressed
                await _sendCommentMethod(
                    commentsCubit: commentsCubit,
                    postId: postId,
                    myUserModel: myUserModel);
              },
              // Show a loading indicator if a comment is being sent or image is uploading
              icon: state is AddCommentLoading ||
                      state is UploadCommentImageLoadingState ||
                      state is GetCommentsLoading
                  ? const CircleAvatar(
                      radius: 10,
                      child: CircularProgressIndicator(
                        color: defaultTextColor,
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

  /// Handles sending a comment, with or without an attached image.
  Future<void> _sendCommentMethod(
      {required CommentsCubit commentsCubit,
      required String postId,
      required UserModel myUserModel}) async {
    // Get the current date and time (to the minute)
    final DateTime now = DateTime.now();
    final currentTime =
        DateTime(now.year, now.month, now.day, now.hour, now.minute);

    // If an image is picked, upload it and include it in the comment
    if (commentsCubit.pickedImage != null) {
      String? commentPhoto =
          await commentsCubit.uploadImageToFirebase(commentsCubit.pickedImage!);
      if (commentPhoto != null) {
        // Create a comment model with the uploaded image
        CommentModel commentModel = CommentModel(
          userName: '${myUserModel.firstName} ${myUserModel.lastName}',
          comment: commentsCubit.commentController.text,
          profilePhoto: myUserModel.photo,
          commentPhoto: commentPhoto,
          dateTime: currentTime,
          userUid: myUserModel.uid,
        );
        // Add the comment and clear the input after success
        await commentsCubit
            .addComment(
          postId: postId,
          commentModel: commentModel,
        )
            .then((value) {
          // Remove comment text and image after adding comment successfully
          commentsCubit.commentController.clear();
          commentsCubit.removeImage();
        });
      }
    }
    // If only text is entered, send the comment without an image
    else if (commentsCubit.commentController.text.isNotEmpty) {
      CommentModel commentModel = CommentModel(
        userName: '${myUserModel.firstName} ${myUserModel.lastName}',
        comment: commentsCubit.commentController.text,
        profilePhoto: myUserModel.photo,
        commentPhoto: null,
        dateTime: currentTime,
        userUid: myUserModel.uid,
      );
      // Add the comment and clear the input after success
      commentsCubit
          .addComment(
        postId: postId,
        commentModel: commentModel,
      )
          .then(
        (value) {
          // Remove comment text and image after adding comment successfully
          commentsCubit.commentController.clear();
          commentsCubit.removeImage();
        },
      );
    }
  }
}
