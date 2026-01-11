import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/shared/bloc/login_cubit/login_cubit.dart';
import 'package:social_media_app/shared/components/custom_button.dart';
import 'package:social_media_app/shared/components/text_form_field.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';
import '../../../shared/style/theme/constant.dart';

class LoginFieldsAndButton extends StatelessWidget {
  const LoginFieldsAndButton({super.key});

  @override
  Widget build(BuildContext context) {
    FocusNode passwordFocus = FocusNode();

    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        LoginCubit loginCubit = BlocProvider.of<LoginCubit>(context);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CustomTextField(
              hintText: 'Email',
              textInputType: TextInputType.emailAddress,
              controller: loginCubit.emailController,
              onFieldSubmitted: (v) {
                FocusScope.of(context).requestFocus(passwordFocus);
              },
            ),
            const SizedBox(
              height: 15,
            ),
            CustomTextField(
              hintText: 'Password',
              focusNode: passwordFocus,
              obscureText: loginCubit.isObscure,
              controller: loginCubit.passwordController,
              textInputType: TextInputType.visiblePassword,
              onFieldSubmitted: (v) async {
                if (loginCubit.formKey.currentState!.validate()) {
                  await loginCubit.loginUser(
                      email: loginCubit.emailController.text,
                      password: loginCubit.passwordController.text);
                } else {
                  loginCubit.noticeTextFormFieldValidation();
                }
              },
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
            const SizedBox(
              height: 15,
            ),
            AbsorbPointer(
              absorbing: state is SendPasswordResetEmailLoading,
              child: TextButton(
                onPressed: () async {
                  String email = loginCubit.emailController.text.trim();
                  if (email.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter your email first'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  await loginCubit.sendPasswordResetEmail(email);
                },
                child: Text(
                  'Forgot password?',
                  style: FontsStyle.font18PopinWithShadowOption(
                    color: defaultTextColor,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            CustomButton(
              text: 'Sign in',
              isLoading: state is LoginLoadingState,
              onTap: () async {
                if (loginCubit.formKey.currentState!.validate()) {
                  await loginCubit.loginUser(
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
