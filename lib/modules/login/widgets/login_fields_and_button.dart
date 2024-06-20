import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/layout/home/home_view.dart';
import 'package:social_media_app/shared/bloc/login_cubit/login_cubit.dart';
import 'package:social_media_app/shared/components/constants.dart';
import 'package:social_media_app/shared/components/custom_button.dart';
import 'package:social_media_app/shared/components/navigators.dart';
import 'package:social_media_app/shared/components/show_toast.dart';
import 'package:social_media_app/shared/components/text_form_field.dart';
import 'package:social_media_app/shared/network/local/cache_helper.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';

import '../../../shared/style/theme/constant.dart';

class LoginFieldsAndButton extends StatelessWidget {
  const LoginFieldsAndButton({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;

    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginFailureState) {
          showToast(msg: state.errMessage, toastState: ToastState.error);
        }
        if (state is LoginSuccessState) {
          CacheHelper.setData(key: uidToken, value: state.uid);
          pushAndRemoveView(context, newRouteName: HomeView.routeViewName);
        }
      },
      builder: (context, state) {
        LoginCubit loginCubit = BlocProvider.of<LoginCubit>(context);

        return Column(
          children: [
            CustomTextField(
              hintText: 'Email/phone number',
              textInputType: TextInputType.emailAddress,
              controller: loginCubit.emailController,
            ),
            SizedBox(
              height: height * 0.02,
            ),
            CustomTextField(
              hintText: 'Password',
              obscureText: loginCubit.isObscure,
              controller: loginCubit.passwordController,
              textInputType: TextInputType.visiblePassword,
              suffixIcon: IconButton(
                onPressed: () {
                  loginCubit.changeTextFieldObscure();
                },
                icon: Icon(
                  loginCubit.eyeIcon,
                  size: 32,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(
              height: height * 0.02,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Forgot password?',
                    style: FontsStyle.font18Popin(
                      color: defaultColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: height * 0.02,
            ),
            CustomButton(
              text: 'Sign in',
              isLoading: state is LoginloadingSatate,
              onTap: () {
                if (loginCubit.formKey.currentState!.validate()) {
                  loginCubit.loginUser(
                      email: loginCubit.emailController.text,
                      password: loginCubit.passwordController.text);
                } else {
                  loginCubit.noticeTextFormFieldValidation();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
