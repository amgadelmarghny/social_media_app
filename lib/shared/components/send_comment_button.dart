import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/style/fonts/font_style.dart';
import '../../../shared/style/theme/constant.dart';
import '../bloc/comments_cubit/comments_cubit.dart';

class SendCommentButton extends StatelessWidget {
  const SendCommentButton({
    super.key,
    required this.onPressed,
  });
  final Function() onPressed;

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
            onPressed: onPressed,
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
        }),
        hintText: 'Write a comment...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
}
