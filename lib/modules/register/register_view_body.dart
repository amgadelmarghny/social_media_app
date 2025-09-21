import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/layout/home/home_view.dart';
import 'package:social_media_app/modules/login/login_view.dart';
import 'package:social_media_app/modules/register/widgets/bloc_consumer_button.dart';
import 'package:social_media_app/modules/register/widgets/register_text_fields.dart';
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: BlocConsumer<RegisterCubit, RegisterState>(
          listener: (context, state) {
            if (state is RegisterFailureState) {
              showToast(msg: state.errMessage, toastState: ToastState.error);
            }
            if (state is SaveUserInfoFailureState) {
              showToast(msg: state.errMessage, toastState: ToastState.error);
            }
            if (state is SaveUserInfoSuccessState) {
              CacheHelper.setData(key: kUidToken, value: state.uid);
              pushAndRemoveView(context, newRouteName: HomeView.routeViewName);
            }
          },
          builder: (context, state) {
            RegisterCubit registerCubit =
                BlocProvider.of<RegisterCubit>(context);
            return Form(
              key: registerCubit.formKey,
              autovalidateMode: registerCubit.autoValidateMode,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Text(
                      'Sign up',
                      style: FontsStyle.font32Bold,
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(
                      height: 30,
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: RegisterTextFields(),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        BlocConsumerButton(
                          emailController: registerCubit.emailController,
                          firstNameController:
                              registerCubit.firstNameController,
                          lastNameController: registerCubit.lastNameController,
                          dateAndMonthController:
                              registerCubit.dateAndMonthController,
                          yearController: registerCubit.yearController,
                          userNameController: registerCubit.userNameController,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'I have an account',
                              style: FontsStyle.font18Popin(isShadow: true),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamedAndRemoveUntil(context,
                                    LoginView.routeViewName, (route) => false);
                              },
                              child: Text(
                                'Sign in',
                                style: FontsStyle.font18Popin(
                                    color: defaultTextColor),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
