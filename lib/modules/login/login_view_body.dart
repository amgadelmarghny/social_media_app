import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/modules/login/widgets/sign_up_navigator_row.dart';
import 'package:social_media_app/shared/bloc/login_cubit/login_cubit.dart';
import 'package:social_media_app/shared/components/auth_icon_list.dart';
import 'package:social_media_app/shared/components/navigators.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';
import '../../layout/home/home_view.dart';
import '../../shared/components/constants.dart';
import '../../shared/components/show_toast.dart';
import '../../shared/network/local/cache_helper.dart';
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
      child: BlocConsumer<LoginCubit, LoginState>(
        listener: (BuildContext context, LoginState state) {
          if (state is LoginSuccessState) {
            CacheHelper.setData(key: kUidToken, value: state.uid);
            pushAndRemoveView(context, newRouteName: HomeView.routeViewName);
          }
          if (state is LoginFailureState) {
            showToast(msg: state.errMessage, toastState: ToastState.error);
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
                  Text(
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
                        style: FontsStyle.font18PopinWithShadowOption(),
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
                  const SignUpNavigatorRow()
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
