import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
                    ),
                  ),
                  Spacer(
                    flex: 1,
                  ),
                  Expanded(
                    flex: 6,
                    child: CustomTextField(
                      hintText: 'Last Name',
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: h * 0.02,
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
              Text(
                'Birth of date',
                style: FontsStyle.font18Popin(),
              ),
              SizedBox(
                height: h * 0.02,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: CustomTextField(
                      hintText: 'Date/month',
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'lib/assets/images/arrow_bottom.svg',
                            height: 20,
                          ),
                        ],
                      ),
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
                      onTap: () async {
                        yearController.text = await pickYear(context: context);
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
                height: h * 0.02,
              ),
              Text(
                'Gender',
                style: FontsStyle.font18Popin(),
              ),
              SizedBox(
                height: h * 0.02,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

