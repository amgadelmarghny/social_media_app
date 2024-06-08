import 'package:flutter/material.dart';
import 'package:social_media_app/layout/home/components/custom_bottom_nav_bar.dart';
import 'package:social_media_app/shared/style/theme/theme.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key}); // Corrected constructor
  static const routeViewName = 'home view';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: themeColor(),
      child: const Scaffold(
        bottomNavigationBar: Padding(
          padding: EdgeInsets.all(8.0),
          child: CustomBottomNavBat(),
        ),
        body: Center(child: Text('Your Page Content')),
      ),
    );
  }
}
