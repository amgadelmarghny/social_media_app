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
    double height = MediaQuery.sizeOf(context).height;

    return BlocBuilder<LoginCubit, LoginState>(
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
                  onPressed: () async {
                    String email = loginCubit.emailController.text.trim();
                    if (email.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('يرجى إدخال البريد الإلكتروني أولاً'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    try {
                      await loginCubit.sendPasswordResetEmail(email);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'تم إرسال رابط إعادة تعيين كلمة المرور إلى $email'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('خطأ: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: Text(
                    'Forgot password?',
                    style: FontsStyle.font18PopinWithShadowOption(
                      color: defaultTextColor,
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
              isLoading: state is LoginLoadingState,
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
            SizedBox(height: height * 0.02),
            // زر اختبار Firebase مؤقت - يمكن حذفه لاحقاً
            TextButton(
              onPressed: () async {
                try {
                  await loginCubit.testFirebaseConnection();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            '✅ اختبار Firebase نجح - الاتصال يعمل بشكل صحيح'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ اختبار Firebase فشل: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(
                'Test Firebase Connection',
                style: FontsStyle.font18PopinWithShadowOption(
                  color: Colors.orange,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
