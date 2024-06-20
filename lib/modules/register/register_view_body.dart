import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/layout/home/home_view.dart';
import 'package:social_media_app/modules/login/login_view.dart';
import 'package:social_media_app/modules/register/widgets/register_fields_and_button.dart';
import 'package:social_media_app/shared/network/local/cache_helper.dart';
import 'package:social_media_app/shared/bloc/register_cubit/register_cubit.dart';
import 'package:social_media_app/shared/components/constants.dart';
import 'package:social_media_app/shared/components/navigators.dart';
import 'package:social_media_app/shared/components/show_toast.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';

import '../../shared/style/theme/constant.dart';

class RegisterViewBody extends StatelessWidget {
  const RegisterViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;

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
                autovalidateMode: registerCubit.autoValidateMode,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sign up',
                      style: FontsStyle.font32Bold,
                    ),
                    SizedBox(
                      height: height * 0.03,
                    ),
                    const RegisterFieldsAndButton(),
                    SizedBox(
                      height: height * 0.0125,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'I have an account',
                          style: FontsStyle.font18Popin(isShadow: true),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(context,
                                LoginView.routeViewName, (route) => false);
                          },
                          child: Text(
                            'Sign in',
                            style: FontsStyle.font18Popin(color: defaultColor),
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
      ),
    );
  }
}
