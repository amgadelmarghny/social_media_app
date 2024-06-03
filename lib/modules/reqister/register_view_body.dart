import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:social_media_app/modules/login/login_view.dart';
import 'package:social_media_app/shared/bloc/register_cubit/register_cubit.dart';
import 'package:social_media_app/shared/components/custom_button.dart';
import 'package:social_media_app/shared/components/gender_icon_list.dart';
import 'package:social_media_app/shared/components/textformfield.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';
import '../../shared/components/year_picker.dart';

class RegisterViewBody extends StatelessWidget {
  const RegisterViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.sizeOf(context).height;
    TextEditingController yearController = TextEditingController();
    TextEditingController firstNameController = TextEditingController();
    TextEditingController lastNameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController dateAndMonthController = TextEditingController();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: BlocBuilder<RegisterCubit, RegisterState>(
          builder: (context, state) {
            return SingleChildScrollView(
              child: Form(
                key: BlocProvider.of<RegisterCubit>(context).formKey,
                autovalidateMode:
                    BlocProvider.of<RegisterCubit>(context).autovalidateMode,
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
                    Row(
                      children: [
                        Expanded(
                          flex: 6,
                          child: CustomTextField(
                            hintText: 'First Name',
                            controller: firstNameController,
                            textInputType: TextInputType.name,
                          ),
                        ),
                        const Spacer(
                          flex: 1,
                        ),
                        Expanded(
                          flex: 6,
                          child: CustomTextField(
                            hintText: 'Last Name',
                            textInputType: TextInputType.name,
                            controller: lastNameController,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: h * 0.02,
                    ),
                    CustomTextField(
                      hintText: 'Email/phone number',
                      textInputType: TextInputType.emailAddress,
                      controller: emailController,
                    ),
                    SizedBox(
                      height: h * 0.02,
                    ),
                    CustomTextField(
                      hintText: 'Password',
                      textInputType: TextInputType.visiblePassword,
                      obscureText:
                          BlocProvider.of<RegisterCubit>(context).isObscure,
                      controller: passwordController,
                      suffixIcon: IconButton(
                        onPressed: () {
                          BlocProvider.of<RegisterCubit>(context)
                              .changeTextFieldObscure();
                        },
                        icon: Icon(
                          BlocProvider.of<RegisterCubit>(context).eyeIcon,
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
                        Expanded(
                          flex: 4,
                          child: CustomTextField(
                            hintText: 'Date/month',
                            textInputType: TextInputType.datetime,
                            controller: dateAndMonthController,
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
                              String? selectedYear =
                                  await pickYear(context: context);
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
                    Column(
                      children: [
                        CustomButton(
                          text: 'Sign up',
                          onTap: () {
                            if (BlocProvider.of<RegisterCubit>(context)
                                .formKey
                                .currentState!
                                .validate()) {
                              BlocProvider.of<RegisterCubit>(context)
                                  .userRegister(
                                email: emailController.text,
                                password: emailController.text,
                              );
                            } else {
                              BlocProvider.of<RegisterCubit>(context)
                                  .noticeTextFormFieldValidation();
                            }
                          },
                          isLoading: state is RegisterLoadingState,
                        ),
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
                                Navigator.pushNamedAndRemoveUntil(context,
                                    LoginView.routeViewName, (route) => false);
                              },
                              child: Text(
                                'Sign in',
                                style: FontsStyle.font18Popin(
                                  color: const Color(0xff3B21B2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
