import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:social_media_app/modules/feeds/widgets/comments_sheet.dart';
import 'package:social_media_app/modules/feeds/widgets/users_suggestion_sheet.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import '../../../shared/style/fonts/font_style.dart';

class InteractiveRow extends StatelessWidget {
  const InteractiveRow({
    super.key,
    required this.numOfLikes,
    required this.isLike,
    this.onLikeButtonTap,
    required this.postId,
    this.showCommentSheet = true,
    required this.commentsNum,
    required this.creatorUid,
  });

  final int numOfLikes, commentsNum;
  final String postId, creatorUid;
  final bool isLike;
  final void Function()? onLikeButtonTap;
  final bool showCommentSheet;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        BlocBuilder<SocialCubit, SocialState>(
          builder: (context, state) {
            return AbsorbPointer(
              absorbing: state is ToggleLikeLoadingState,
              child: IconButton(
                onPressed: onLikeButtonTap,
                icon: isLike
                    ? SvgPicture.asset(
                        'lib/assets/images/like.svg',
                      )
                    : const Icon(Icons.favorite_border),
              ),
            );
          },
        ),
        if (numOfLikes > 0)
          Transform.translate(
            offset: const Offset(-7, 0),
            child: InkWell(
              onTap: () async {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) {
                    return FractionallySizedBox(
                      heightFactor:
                          1.0, // This makes the bottom sheet take the full height
                      child: UsersSuggestionsSheet(
                        userModelList:
                            context.read<SocialCubit>().userModelList,
                      ),
                    );
                  },
                );
                await context
                    .read<SocialCubit>()
                    .getUsersLikesInPost(postId: postId);
              },
              child: Text(
                numOfLikes.toString(),
                style: FontsStyle.font18PopinWithShadowOption(),
              ),
            ),
          ),
        const SizedBox(
          width: 5,
        ),
        GestureDetector(
          onTap: showCommentSheet
              ? () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) {
                      return FractionallySizedBox(
                        heightFactor:
                            1.0, // This makes the bottom sheet take the full height
                        child: CommentsSheet(
                          postId: postId,
                          commentsNum: commentsNum,
                          creatorUid: creatorUid,
                        ),
                      );
                    },
                  );
                }
              : null,
          child: Row(
            children: [
              SvgPicture.asset(
                'lib/assets/images/comments.svg',
              ),
              const SizedBox(
                width: 5,
              ),
              if (commentsNum > 0)
                Text(
                  commentsNum.toString(),
                  style: FontsStyle.font18PopinWithShadowOption(),
                )
            ],
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () {},
          icon: SvgPicture.asset(
            'lib/assets/images/share.svg',
          ),
        ),
      ],
    );
  }
}
