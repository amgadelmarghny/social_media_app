import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:social_media_app/models/user_model.dart';
import 'package:social_media_app/modules/feeds/widgets/comments_sheet.dart';
import 'package:social_media_app/shared/bloc/comments_cubit/comments_cubit.dart';
import 'package:social_media_app/shared/style/theme/constant.dart';
import '../../../shared/style/fonts/font_style.dart';

class InteractiveRow extends StatelessWidget {
  const InteractiveRow({
    super.key,
    required this.numOfLikes,
    required this.isLike,
    this.onLikeButtonTap,
    required this.postId,
    required this.userModel,
  });

  final int numOfLikes;
  final String postId;
  final bool isLike;
  final void Function()? onLikeButtonTap;
  final UserModel userModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onLikeButtonTap,
          icon: isLike
              ? SvgPicture.asset(
                  'lib/assets/images/like.svg',
                )
              : const Icon(Icons.favorite_border),
          color: defaultColor,
        ),
        if (numOfLikes > 0)
          Transform.translate(
            offset: const Offset(-7, 0),
            child: Text(
              numOfLikes.toString(),
              style: FontsStyle.font18Popin(),
            ),
          ),
        const SizedBox(
          width: 5,
        ),
        InkWell(
          splashColor: const Color(0xff8862D9),
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) {
                return FractionallySizedBox(
                  heightFactor:
                      1.0, // This makes the bottom sheet take the full height
                  child: CommentsSheet(
                    postId: postId,
                    userModel: userModel,
                  ),
                );
              },
            );
          },
          child: BlocBuilder<CommentsCubit, CommentsState>(
              builder: (context, state) {
            return Row(
              children: [
                SvgPicture.asset(
                  'lib/assets/images/comments.svg',
                ),
                const SizedBox(
                  width: 5,
                ),
                if (BlocProvider.of<CommentsCubit>(context).numberOfComment > 0)
                  Text(
                    BlocProvider.of<CommentsCubit>(context)
                        .numberOfComment
                        .toString(),
                    style: FontsStyle.font18Popin(),
                  )
              ],
            );
          }),
        ),
        const Spacer(),
        IconButton(
          onPressed: () {},
          icon: SvgPicture.asset(
            'lib/assets/images/share.svg',
          ),
          color: defaultColor,
        ),
      ],
    );
  }
}
