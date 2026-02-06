import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:social_media_app/modules/login/widgets/sign_up_navigator_row.dart';
import 'package:social_media_app/shared/bloc/login_cubit/login_cubit.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: BlocConsumer<LoginCubit, LoginState>(
        listener: (BuildContext context, LoginState state) {
          if (state is LoginSuccessState) {
            CacheHelper.setData(key: kUidToken, value: state.uid);
            // Update SocialCubit with new user data after login
            final socialCubit = BlocProvider.of<SocialCubit>(context);
            socialCubit.uidTokenCache = state.uid;
            socialCubit.getUserData(userUid: state.uid);
            socialCubit.getMyUserPosts(state.uid);
            socialCubit.getTimelinePosts();
            socialCubit.getFollowers();
            socialCubit.getFollowing();
            pushAndRemoveView(context, newRouteName: HomeView.routeViewName);
          }
          if (state is LoginFailureState) {
            showToast(msg: state.errMessage, toastState: ToastState.error);
          }
          if (state is SendPasswordResetEmailSuccess) {
            showToast(msg: state.message, toastState: ToastState.success);
          }
          if (state is SendPasswordResetEmailFailure) {
            showToast(msg: state.errMessage, toastState: ToastState.error);
          }
        },
        builder: (context, state) {
          LoginCubit loginCubit = BlocProvider.of<LoginCubit>(context);
          return Form(
            key: loginCubit.formKey,
            autovalidateMode: loginCubit.autovalidateMode,
            child: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 50,
                  ),
                ),
                SliverToBoxAdapter(
                  child: FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    child: const Image(
                      height: 100,
                      image: AssetImage(
                        'lib/assets/images/launch_icon_wthout_bg.png',
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 20,
                  ),
                ),
                SliverToBoxAdapter(
                  child: FadeInLeft(
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      'Sign in',
                      style: FontsStyle.font32Bold,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 20,
                  ),
                ),
                SliverToBoxAdapter(
                  child: FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    child: const LoginFieldsAndButton(),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 15,
                  ),
                ),
                //TODO: Applay sign in with facebock and google.
                // SliverToBoxAdapter(
                //   child: Text(
                //     'Or sign in with',
                //     textAlign: TextAlign.center,
                //     style: FontsStyle.font18PopinWithShadowOption(),
                //   ),
                // ),
                // const SliverToBoxAdapter(
                //   child: SizedBox(
                //     height: 10,
                //   ),
                // ),
                // const SliverToBoxAdapter(child: AuthIocnList()),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Align(
                      alignment: AlignmentGeometry.bottomCenter,
                      child: FadeIn(
                        duration: const Duration(seconds: 1),
                        child: const SignUpNavigatorRow(),
                      )),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
