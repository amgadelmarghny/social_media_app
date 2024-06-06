import 'package:flutter/material.dart';
import 'package:social_media_app/modules/login/login_view_body.dart';
import '../../shared/style/theme/theme.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});
  static const routeViewName = 'login view';
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: themeColor(),
      child: const Scaffold(
        body: LodinViewBody(),
      ),
    );
  }
}
