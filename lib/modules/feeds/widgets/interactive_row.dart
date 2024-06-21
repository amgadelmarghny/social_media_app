import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:social_media_app/shared/style/theme/constant.dart';
import '../../../shared/style/fonts/font_style.dart';

class InteractiveRow extends StatelessWidget {
  const InteractiveRow({
    super.key,
    required this.numOfLikes,
    required this.numOfComments,
  });
  final String numOfLikes;
  final String numOfComments;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {},
          icon: SvgPicture.asset(
            'lib/assets/images/like.svg',
          ),
          color: defaultColor,
        ),
        Transform.translate(
          offset: const Offset(-7, 0),
          child: Text(
            numOfLikes,
            style: FontsStyle.font18Popin(),
          ),
        ),
        GestureDetector(
          onTap: () {},
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
