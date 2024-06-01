import 'package:flutter/material.dart';
import 'package:social_media_app/modules/reqister/reqister_view.dart';
import 'package:social_media_app/shared/components/auth_icon_list.dart';
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
              style: FontsStyle.font32Bold,
            ),
            SizedBox(
              height: h * 0.03,
            ),
            const CustomTextField(
              hintText: 'Email/phone number',
            ),
            SizedBox(
              height: h * 0.02,
            ),
            CustomTextField(
              hintText: 'Password',
              obscureText: isObscure,
              suffixIcon: IconButton(
                onPressed: () {
                  isObscure = !isObscure;
                  setState(() {});
                },
                icon: Icon(
                  isObscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 32,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(
              height: h * 0.02,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Forgot password?',
                    style: FontsStyle.font18Popin(
                      color: const Color(0xff3B21B2),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: h * 0.02,
            ),
            CustomButton(text: 'Sign in', onTap: () {}),
            SizedBox(
              height: h * 0.02,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Or sign in with',
                  style: FontsStyle.font18Popin(),
                ),
              ],
            ),
            SizedBox(
              height: h * 0.0125,
            ),
            const AuthIocnList(),
            SizedBox(
              height: h * 0.0125,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Don\'t have an account?',
                  style: FontsStyle.font18Popin(),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, RegisterView.routeNameView, (route) => false);
                  },
                  child: Text(
                    'Sign up',
                    style: FontsStyle.font18Popin(
                      color: const Color(0xff3B21B2),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
