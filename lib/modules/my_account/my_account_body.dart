import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/modules/feeds/widgets/upload_post_demo_widget.dart';
import 'package:social_media_app/modules/my_account/widgets/custom_cover_and_image_profile.dart';
import 'package:social_media_app/modules/my_account/widgets/my_account_name_and_update_button.dart';
import 'package:social_media_app/modules/my_account/widgets/my_followers_and_followind_and_bio_account.dart';
import 'package:social_media_app/modules/my_account/widgets/my_sliver_posts_list_account.dart';
import 'package:social_media_app/shared/bloc/user_cubit/user_cubit.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import 'package:social_media_app/shared/components/constants.dart';
import 'package:social_media_app/shared/components/custom_refresh_indicator.dart';
import 'package:social_media_app/shared/components/show_toast.dart';

/// The main body widget for the user's own account/profile page.
/// Displays cover, profile image, name, edit button, stats, follow/message buttons, bio, and a grid of images.
class UsersBody extends StatefulWidget {
  const UsersBody({super.key});

  @override
  State<UsersBody> createState() => _UsersBodyState();
}

class _UsersBodyState extends State<UsersBody> {
  // Controller for handling scroll events in the users body.
  final ScrollController _scrollController = ScrollController();

  // Padding at the bottom of the users body, adjusted based on scroll.
  double _bodiesBottomPadding = 36;

  // Store the current user's data separately to avoid conflicts

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
    // Provide a UserCubit for managing follow state and current user data.
    return BlocProvider(
      create: (context) => UserCubit(),
      child: NotificationListener<ScrollNotification>(
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
          // Listen for various SocialCubit states to show toasts for errors/success.
          listener: (context, state) {
            if (state is PickImageFailureState) {
              showToast(msg: state.errMessage, toastState: ToastState.worrning);
            }
            if (state is UploadProfileImageFailureState) {
              showToast(msg: state.errMessage, toastState: ToastState.worrning);
            }
            if (state is UploadCoverImageFailureState) {
              showToast(msg: state.errMessage, toastState: ToastState.worrning);
            }
            if (state is UploadCoverImageSuccessState ||
                state is UploadProfileImageSuccessState) {
              showToast(
                  msg: 'Added successfully', toastState: ToastState.success);
            }
          },
          builder: (context, state) {
            SocialCubit socialCubit = context.read<SocialCubit>();

            return Padding(
              padding: EdgeInsets.only(bottom: _bodiesBottomPadding),
              child: CustomRefreshIndicator(
                onRefresh: () async {
                  await socialCubit.getMyUserPosts(kUidToken);
                },
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    // Cover and profile image section
                    SliverToBoxAdapter(
                      child: CustomCoverAndImageProfile(
                        profileImage: socialCubit.userModel?.photo,
                        profileCover: socialCubit.userModel?.cover,
                        isUsedInMyAccount: true,
                      ),
                    ),
                    // Name and edit profile button row
                    const MyAccountNameAndUpdateButton(),
                    // Stats row (posts, followers, following), follow/message buttons, and bio
                    const MyFollowersAndFollowindAndBioAccount(),
                    // upload post demo
                    if (socialCubit.postContentController.text.isNotEmpty ||
                        socialCubit.postImagePicked != null)
                      if (state is CreatePostLoadingState ||
                          // if failure show keep showing this widget
                          // to cancel adding post or upload it again
                          state is UploadPostImageFailureState ||
                          state is CreatePostFailureState)
                        const SliverToBoxAdapter(child: UploadPostDemo()),
                    //user's posts
                    const MySliverPostsListAccount(),
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
