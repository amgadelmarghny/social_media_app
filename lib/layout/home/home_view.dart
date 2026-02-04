import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:social_media_app/layout/home/components/custom_bottom_nav_bar.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import 'package:social_media_app/shared/components/show_toast.dart';
import 'package:social_media_app/shared/style/theme/theme.dart';
import 'package:upgrader/upgrader.dart';

/// The main HomeView widget, which is a StatefulWidget.
/// This is the entry point for the home screen of the app.
class HomeView extends StatefulWidget {
  const HomeView({super.key});
  static const routeViewName = 'home view';

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late SocialCubit socialCubit;
  @override
  void initState() {
    socialCubit = SocialCubit();
    // request notification permissions when the HomeView is first created.
    requestNotificationPermision();
    super.initState();
  }

  /// Requests notification permissions from the user.
  /// Shows a toast message based on the user's response.

  Future<void> requestNotificationPermision() async {
    await Permission.notification.request();
  }

  @override
  Widget build(BuildContext context) {
    // The main build method for the HomeView.
    return Container(
      decoration:
          themeColor(), // Set the background theme using a custom function.
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
        child: Stack(
          children: [
            // Main content area of the app.
            Scaffold(
              body: UpgradeAlert(
                dialogStyle: UpgradeDialogStyle.material,
                upgrader: Upgrader(
                  durationUntilAlertAgain: const Duration(days: 1),
                ),
                child: BlocConsumer<SocialCubit, SocialState>(
                  // Listen for error states and show toasts if needed.
                  listener: (context, state) {
                    if (state is GetMyDataFailureState) {
                      // Show an error toast if user data fails to load.
                      showToast(
                          msg: state.errMessage, toastState: ToastState.error);
                    }
                    if (state is GetFeedsPostsFailureState) {
                      // Show an error toast if feed posts fail to load.
                      showToast(
                          msg: state.errMessage, toastState: ToastState.error);
                    }
                  },
                  builder: (context, state) {
                    // If user data failed to load, show an error message in the center of the screen.
                    if (state is GetMyDataFailureState) {
                      return const Center(
                        child: Text('Something went wrong'),
                      );
                    }
                    // Only show the main content if user data and posts are loaded.
                    // The currentBody is selected based on the currentBottomNavBarIndex from the SocialCubit.
                    return BlocProvider.of<SocialCubit>(context).currentBody[
                        BlocProvider.of<SocialCubit>(context)
                            .currentBottomNavBarIndex];
                  },
                ),
              ),
            ),
            // The custom bottom navigation bar, always aligned to the bottom of the screen.
            const Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: CustomBottomNavBar(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
