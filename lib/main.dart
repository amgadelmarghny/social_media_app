import 'package:flutter/material.dart';
import 'package:social_media_app/modules/on_boarding/on_boarding_view.dart';

void main() {
  runApp(const SocialMediaApp());
}

class SocialMediaApp extends StatelessWidget {
  const SocialMediaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: OnBoardingView.routeViewName,
      routes: {
        OnBoardingView.routeViewName: (context) => const OnBoardingView(),
      },
    );
  }
}
