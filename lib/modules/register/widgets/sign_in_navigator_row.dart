import 'package:flutter/material.dart';
import 'package:social_media_app/modules/login/login_view.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';
import 'package:social_media_app/shared/style/theme/constant.dart';

class SigninNavigaorRow extends StatelessWidget {
  const SigninNavigaorRow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'I have an account',
          style: FontsStyle.font18PopinWithShadowOption(
              isShadow: true),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context,
                LoginView.routeViewName, (route) => false);
          },
          child: Text(
            'Sign in',
            style: FontsStyle.font18PopinWithShadowOption(
                color: defaultTextColor),
          ),
        ),
      ],
    );
  }
}