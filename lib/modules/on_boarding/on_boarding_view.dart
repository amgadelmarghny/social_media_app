import 'package:flutter/material.dart';
import 'package:social_media_app/modules/on_boarding/on_bording_view_body.dart';

class OnBoardingView extends StatelessWidget {
  const OnBoardingView({super.key});
  static const String routeViewName = "onBoardingView";
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xffCEA6E7),
      body: OnBoardingViewBody(),
    );
  }
}
