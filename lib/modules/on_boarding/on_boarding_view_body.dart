import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:social_media_app/modules/on_boarding/widgets/container_page_view.dart';

class OnBoardingViewBody extends StatelessWidget {
  const OnBoardingViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Image(
          image: AssetImage('lib/assets/images/on_boarding.png'),
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        CustomContainerPageView(),
      ],
    );
  }
}
