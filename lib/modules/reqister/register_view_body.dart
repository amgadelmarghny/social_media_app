import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:social_media_app/layout/home/home_view.dart';
import 'package:social_media_app/modules/login/login_view.dart';
import 'package:social_media_app/shared/bloc/network/local/cache_helper.dart';
import 'package:social_media_app/shared/bloc/register_cubit/register_cubit.dart';
import 'package:social_media_app/shared/components/constants.dart';
import 'package:social_media_app/shared/components/custom_button.dart';
import 'package:social_media_app/shared/components/gender_icon_list.dart';
import 'package:social_media_app/shared/components/navigators.dart';
import 'package:social_media_app/shared/components/show_toast.dart';
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
        child: BlocConsumer<RegisterCubit, RegisterState>(
          listener: (context, state) {
            if (state is RegisterFailureState) {
              showToast(msg: state.errMessage, toastState: ToastState.error);
            }
            if (state is SaveUserInfoFailureState) {
              showToast(msg: state.errMessage, toastState: ToastState.error);
            }
            if (state is SaveUserInfoSuccessState) {
              CacheHelper.setData(key: enterToHone, value: true);
              CacheHelper.setData(key: uidToken, value: state.uid);
              pushAndRemoveView(context, newRouteName: HomeView.routeViewName);
            }
          },
          builder: (context, state) {
            RegisterCubit registerCubit =
                BlocProvider.of<RegisterCubit>(context);
            return SingleChildScrollView(
              child: Form(
                key: registerCubit.formKey,
                autovalidateMode: registerCubit.autovalidateMode,
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
                      obscureText: registerCubit.isObscure,
                      controller: passwordController,
                      suffixIcon: IconButton(
                        onPressed: () {
                          registerCubit.changeTextFieldObscure();
                        },
                        icon: Icon(
                          registerCubit.eyeIcon,
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
                            if (registerCubit.formKey.currentState!
                                .validate()) {
                              if (registerCubit.gender != null) {
                                registerCubit.userRegister(
                                    email: emailController.text,
                                    password: emailController.text,
                                    firstName: firstNameController.text,
                                    lastName: lastNameController.text,
                                    dateAndMonth: dateAndMonthController.text,
                                    year: yearController.text,
                                    gender:
                                        BlocProvider.of<RegisterCubit>(context)
                                            .gender!);
                              } else {
                                customSnakbar(context,
                                    msg: 'Please select your gender');
                              }
                            } else {
                              registerCubit.noticeTextFormFieldValidation();
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
