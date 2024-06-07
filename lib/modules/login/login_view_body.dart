import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/layout/home/home_view.dart';
import 'package:social_media_app/modules/reqister/reqister_view.dart';
import 'package:social_media_app/shared/bloc/login_/login_cubit.dart';
import 'package:social_media_app/shared/components/auth_icon_list.dart';
import 'package:social_media_app/shared/components/constants.dart';
import 'package:social_media_app/shared/components/custom_button.dart';
import 'package:social_media_app/shared/components/navigators.dart';
import 'package:social_media_app/shared/components/show_toast.dart';
import 'package:social_media_app/shared/components/textformfield.dart';
import 'package:social_media_app/shared/network/local/cache_helper.dart';
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
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginFailureSatate) {
            showToast(msg: state.errMessage, toastState: ToastState.error);
          }
          if (state is LoginSuccessSatate) {
            CacheHelper.setData(key: uidToken, value: state.uid);
            pushAndRemoveView(context, newRouteName: HomeView.routeViewName);
          }
        },
        builder: (context, state) {
          LoginCubit loginCubit = BlocProvider.of<LoginCubit>(context);
          return SingleChildScrollView(
            child: Form(
              key: loginCubit.formKey,
              autovalidateMode: loginCubit.autovalidateMode,
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
                    obscureText: loginCubit.isObscure,
                    controller: passwordController,
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
                  CustomButton(
                      text: 'Sign in',
                      isLoading: state is LoginloadingSatate,
                      onTap: () {
                        if (loginCubit.formKey.currentState!.validate()) {
                          BlocProvider.of<LoginCubit>(context).loginUser(
                              email: emailController.text,
                              password: passwordController.text);
                        } else {
                          loginCubit.noticeTextFormFieldValidation();
                        }
                      }),
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
                          pushAndRemoveView(context,
                              newRouteName: RegisterView.routeViewName);
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
        },
      ),
    );
  }
}
