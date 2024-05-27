import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:social_media_app/modules/on_boarding/widgets/container_page_view.dart';

class OnBoardingViewBody extends StatelessWidget {
  const OnBoardingViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        // this for hide the rounded upper ege of image
        // by move it up until the bar
        Transform.translate(
          offset: const Offset(0, -12),
          child: Column(
            children: [
              Image.asset(
                'lib/assets/images/on_boarding.png',
                width: double.infinity,
                fit: BoxFit.fill,
              ),
            ],
          ),
        ),
        const CustomContainerPageView(),
      ],
    );
  }
}
