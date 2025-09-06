import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/layout/home/components/custom_bottom_nav_bar.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import 'package:social_media_app/shared/components/constants.dart';
import 'package:social_media_app/shared/components/show_toast.dart';
import 'package:social_media_app/shared/network/local/cache_helper.dart';
import 'package:social_media_app/shared/style/theme/theme.dart';

/// The main HomeView widget, which is a StatefulWidget.
/// This is the entry point for the home screen of the app.
class HomeView extends StatefulWidget {
  const HomeView({super.key});
  static const routeViewName = 'home view';

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Controller for handling scroll events in the main body.
  final ScrollController _scrollController = ScrollController();

  // Padding at the bottom of the main body, adjusted based on scroll.
  double _bodiesBottomPadding = 36;

  @override
  void initState() {
    super.initState();
    // Add a listener to the scroll controller to detect when the user
    // has scrolled to the edge (top or bottom) of the scroll view.
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        bool isTop = _scrollController.position.pixels == 0;
        if (!isTop) {
          // Reached the bottom of the scroll view.
          debugPrint(
              "^^^^^^^ Reached the end of the SingleChildScrollView ^^^");
          // Increase the bottom padding to make space for the bottom nav bar.
          setState(() {
            _bodiesBottomPadding = 82;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Print the current user token for debugging purposes.
    debugPrint('Token ::::: ${CacheHelper.getData(key: kUidToken)}');
    return Container(
      decoration: themeColor(), // Set the background theme.
      child: SafeArea(
        child: Stack(
          children: [
            // Main content area with dynamic bottom padding.
            Padding(
              padding: EdgeInsets.only(bottom: _bodiesBottomPadding),
              child: Scaffold(
                body: NotificationListener<ScrollNotification>(
                  // Listen for scroll updates to adjust bottom padding
                  onNotification: (scrollNotification) {
                    if (scrollNotification is ScrollUpdateNotification) {
                      // If the user scrolls up (forward), reset the bottom padding.
                      if (_scrollController.position.userScrollDirection ==
                          ScrollDirection.forward) {
                        setState(() {
                          _bodiesBottomPadding = 36;
                        });
                      }
                    }
                    return true;
                  },
                  child: BlocConsumer<SocialCubit, SocialState>(
                    // Listen for error states and show toasts if needed.
                    listener: (context, state) {
                      if (state is GetUserDataFailureState) {
                        showToast(
                            msg: state.errMessage,
                            toastState: ToastState.error);
                      }
                      if (state is GetPostsFailureState) {
                        showToast(
                            msg: state.errMessage,
                            toastState: ToastState.error);
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
                      return ConditionalBuilder(
                        condition:
                            BlocProvider.of<SocialCubit>(context).userModel !=
                                null,
                        builder: (context) => SingleChildScrollView(
                          controller: _scrollController,
                          child: BlocProvider.of<SocialCubit>(context)
                                  .currentBody[
                              BlocProvider.of<SocialCubit>(context)
                                  .currentBottomNavBarIndex],
                        ),
                        // Show a loading indicator while data is loading.
                        fallback: (context) => const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ),
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
