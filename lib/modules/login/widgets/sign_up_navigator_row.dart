import 'package:flutter/material.dart';
import 'package:social_media_app/modules/register/register_view.dart';
import 'package:social_media_app/shared/components/navigators.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';
import 'package:social_media_app/shared/style/theme/constant.dart';

class SignUpNavigatorRow extends StatelessWidget {
  const SignUpNavigatorRow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Don\'t have an account?',
          style: FontsStyle.font18PopinWithShadowOption(),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {
            pushAndRemoveView(context,
                newRouteName: RegisterView.routeViewName);
          },
          child: Text(
            'Sign up',
            style: FontsStyle.font18PopinWithShadowOption(
              color: defaultTextColor,
            ),
          ),
        ),
      ],
    );
  }
}