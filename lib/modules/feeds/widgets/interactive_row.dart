import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:social_media_app/modules/feeds/widgets/comments_sheet.dart';
import 'package:social_media_app/shared/style/theme/constant.dart';
import '../../../shared/style/fonts/font_style.dart';
import '../../new_post/new_post.dart';

class InteractiveRow extends StatelessWidget {
  const InteractiveRow({
    super.key,
    required this.numOfLikes,
    required this.numOfComments,
    required this.isLike,
    this.onLikeButtonTap,
  });
  final int numOfLikes;
  final String numOfComments;

  final bool isLike;
  final void Function()? onLikeButtonTap;

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
                return const FractionallySizedBox(
                  heightFactor:
                  1.0, // This makes the bottom sheet take the full height
                  child: CommentsSheet(),
                );
              },
            );
          },
          child: Row(
            children: [
              SvgPicture.asset(
                'lib/assets/images/comments.svg',
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                numOfComments,
                style: FontsStyle.font18Popin(),
              ),
            ],
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () {

          },
          icon: SvgPicture.asset(
            'lib/assets/images/share.svg',
          ),
          color: defaultColor,
        ),
      ],
    );
  }
}
