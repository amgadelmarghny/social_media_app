import 'package:flutter/material.dart';
import 'package:social_media_app/shared/style/theme/theme.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});
  static const routeViewName = 'home view';
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: themeColor(),
      child: const Scaffold(),
    );
  }
}
