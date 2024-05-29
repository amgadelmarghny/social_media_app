import 'package:flutter/material.dart';
import 'package:social_media_app/modules/reqister/register_view_body.dart';
import 'package:social_media_app/shared/style/theme/theme.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});
  static const routeNameView = 'Register View';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: themeColor(),
      child: const Scaffold(
        backgroundColor: Colors.transparent,
        body: RegisterViewBody(),
      ),
    );
  }
}
