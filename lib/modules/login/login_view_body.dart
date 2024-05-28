import 'package:flutter/material.dart';
import 'package:social_media_app/shared/components/textformfield.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';

class LodinViewBody extends StatelessWidget {
  const LodinViewBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.sizeOf(context).height;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: h * 0.15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'lib/assets/images/Ciao.png',
              ),
            ],
          ),
          SizedBox(
            height: h * 0.03,
          ),
          const Text(
            'Sign in',
            style: FontsStyle.font36BoldShadow,
          ),
          SizedBox(
            height: h * 0.03,
          ),
          const CustomTextField(
            hintText: 'Email/phone number',
          )
        ],
      ),
    );
  }
}
