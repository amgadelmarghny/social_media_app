import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';

class CustomReadMoreText extends StatelessWidget {
  const CustomReadMoreText({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return ReadMoreText(
      text,
      trimMode: TrimMode.Line,
      trimLines: 4,
      colorClickableText: Colors.pink,
      trimCollapsedText: 'more',
      trimExpandedText: ' less',
      style: FontsStyle.font18PopinMedium(isEllipsisOverFlow: false),
      lessStyle: FontsStyle.font15Popin(
        color: Colors.white60,
      ),
      moreStyle: FontsStyle.font15Popin(
        color: Colors.white60,
      ),
    );
  }
}
