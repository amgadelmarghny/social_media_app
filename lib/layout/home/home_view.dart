import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/layout/home/components/custom_bottom_nav_bar.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import 'package:social_media_app/shared/components/show_toast.dart';
import 'package:social_media_app/shared/style/theme/theme.dart';

/// The main HomeView widget, which is a StatefulWidget.
/// This is the entry point for the home screen of the app.
class HomeView extends StatelessWidget {
  const HomeView({super.key});
  static const routeViewName = 'home view';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: themeColor(), // Set the background theme.
      child: SafeArea(
        child: Stack(
          children: [
            // Main content area.
            Scaffold(
              body: BlocConsumer<SocialCubit, SocialState>(
                // Listen for error states and show toasts if needed.
                listener: (context, state) {
                  if (state is GetUserDataFailureState) {
                    showToast(
                        msg: state.errMessage, toastState: ToastState.error);
                  }
                  if (state is GetPostsFailureState) {
                    showToast(
                        msg: state.errMessage, toastState: ToastState.error);
                  }
                },
                builder: (context, state) {
                  // If user data failed to load, show an error message.
                  if (state is GetUserDataFailureState) {
                    return const Center(
                      child: Text('Something went wrong'),
                    );
                  }
                  // Only show the main content if user data and posts are loaded.
                  return BlocProvider.of<SocialCubit>(context).currentBody[
                      BlocProvider.of<SocialCubit>(context)
                          .currentBottomNavBarIndex];
                },
              ),
            ),
            // The custom bottom navigation bar, always aligned to the bottom.
            const Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(left: 8, right: 8),
                child: CustomBottomNavBat(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
