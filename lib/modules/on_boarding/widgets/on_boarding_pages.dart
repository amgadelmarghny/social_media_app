import 'package:flutter/material.dart';
import 'package:social_media_app/models/onBoarding/on_boarding_model.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';

class OnBoardingPages extends StatelessWidget {
  const OnBoardingPages({
    super.key,
    required this.onBoardingModel,
  });
  final OnBoardingModel onBoardingModel;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 15,
        ),
        Text(
          onBoardingModel.title,
          style: FontsStyle.font36Bold,
        ),
        Text(
          onBoardingModel.subTitle,
          style: FontsStyle.font20,
        ),
        Row(
          children: [
            const Text(
              'moment with',
              style: FontsStyle.font20,
            ),
            const SizedBox(
              width: 8,
            ),
            Image.asset(
              'lib/assets/images/Ciao.png',
              height: 30,
            ),
          ],
        ),
      ],
    );
  }
}
