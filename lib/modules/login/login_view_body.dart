import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/modules/register/register_view.dart';
import 'package:social_media_app/shared/bloc/login_cubit/login_cubit.dart';
import 'package:social_media_app/shared/components/auth_icon_list.dart';
import 'package:social_media_app/shared/components/navigators.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';
import '../../shared/style/theme/constant.dart';
import 'widgets/login_fields_and_button.dart';

class LoginViewBody extends StatelessWidget {
  const LoginViewBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: BlocBuilder<LoginCubit, LoginState>(
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
                    height: height * 0.15,
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
                    height: height * 0.03,
                  ),
                  const Text(
                    'Sign in',
                    style: FontsStyle.font32Bold,
                  ),
                  SizedBox(
                    height: height * 0.03,
                  ),
                  const LoginFieldsAndButton(),
                  SizedBox(
                    height: height * 0.02,
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
                    height: height * 0.0125,
                  ),
                  const AuthIocnList(),
                  SizedBox(
                    height: height * 0.0125,
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
                            color: defaultColor,
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
