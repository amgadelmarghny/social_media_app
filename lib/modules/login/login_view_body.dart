import 'package:flutter/material.dart';
import 'package:social_media_app/shared/components/custom_button.dart';
import 'package:social_media_app/shared/components/textformfield.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';

class LodinViewBody extends StatefulWidget {
  const LodinViewBody({
    super.key,
  });

  @override
  State<LodinViewBody> createState() => _LodinViewBodyState();
}

class _LodinViewBodyState extends State<LodinViewBody> {
  bool isObscure = true;
  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.sizeOf(context).height;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
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
            ),
            SizedBox(
              height: h * 0.017,
            ),
            CustomTextField(
              hintText: 'Password',
              obscureText: isObscure,
              suffixIcon: isObscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              suffixOnPressed: () {
                isObscure = !isObscure;
                setState(() {});
              },
            ),
            SizedBox(
              height: h * 0.08,
            ),
            CustomButton(text: 'Sign in', onTap: () {}),
            SizedBox(
              height: h * 0.1,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Don\'t have an account?',
                  style: FontsStyle.font20Popin(),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Sign up',
                    style:
                        FontsStyle.font20Popin(color: const Color(0xff3B21B2)),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
