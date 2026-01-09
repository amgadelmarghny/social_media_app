import 'package:flutter/material.dart';
import 'package:social_media_app/modules/on_boarding/on_boarding_view_body.dart';

class OnBoardingView extends StatelessWidget {
  const OnBoardingView({super.key});
  static const String routeViewName = "onBoardingView";
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: OnBoardingViewBody()),
    );
  }
}
