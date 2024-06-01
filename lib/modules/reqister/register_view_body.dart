import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:social_media_app/modules/login/login_view.dart';
import 'package:social_media_app/shared/components/custom_button.dart';
import 'package:social_media_app/shared/components/gender_icon_list.dart';
import 'package:social_media_app/shared/components/textformfield.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';
import '../../shared/components/year_picker.dart';

class RegisterViewBody extends StatefulWidget {
  const RegisterViewBody({super.key});

  @override
  State<RegisterViewBody> createState() => _RegisterViewBodyState();
}

class _RegisterViewBodyState extends State<RegisterViewBody> {
  bool isObscure = true;
  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.sizeOf(context).height;
    TextEditingController yearController = TextEditingController();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sign up',
                style: FontsStyle.font32Bold,
              ),
              SizedBox(
                height: h * 0.03,
              ),
              const Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: CustomTextField(
                      hintText: 'First Name',
                      textInputType: TextInputType.name,
                    ),
                  ),
                  Spacer(
                    flex: 1,
                  ),
                  Expanded(
                    flex: 6,
                    child: CustomTextField(
                      hintText: 'Last Name',
                      textInputType: TextInputType.name,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: h * 0.02,
              ),
              const CustomTextField(
                hintText: 'Email/phone number',
                textInputType: TextInputType.emailAddress,
              ),
              SizedBox(
                height: h * 0.02,
              ),
              CustomTextField(
                hintText: 'Password',
                textInputType: TextInputType.visiblePassword,
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
                height: h * 0.015,
              ),
              Text(
                'Birth of date',
                style: FontsStyle.font18Popin(),
              ),
              SizedBox(
                height: h * 0.015,
              ),
              Row(
                children: [
                  const Expanded(
                    flex: 4,
                    child: CustomTextField(
                      hintText: 'Date/month',
                      textInputType: TextInputType.datetime,
                    ),
                  ),
                  const Spacer(
                    flex: 1,
                  ),
                  Expanded(
                    flex: 3,
                    child: CustomTextField(
                      hintText: 'Year',
                      controller: yearController,
                      textInputType: TextInputType.datetime,
                      onTap: () async {
                        String? selectedYear = await pickYear(context: context);
                        if (selectedYear != null) {
                          yearController.text = selectedYear;
                        }
                      },
                      suffixIcon:
                          Row(mainAxisSize: MainAxisSize.min, children: [
                        SvgPicture.asset(
                          'lib/assets/images/arrow_bottom.svg',
                          height: 20,
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: h * 0.015,
              ),
              Text(
                'Gender',
                style: FontsStyle.font18Popin(),
              ),
              SizedBox(
                height: h * 0.015,
              ),
              const GenderIconList(),
              SizedBox(
                height: h * 0.15,
              ),
              CustomButton(text: 'Sign up', onTap: () {}),
              SizedBox(
                height: h * 0.0125,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'I have an account',
                    style: FontsStyle.font18Popin(),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, LoginView.routeViewName, (route) => false);
                    },
                    child: Text(
                      'Sign in',
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
      ),
    );
  }
}
