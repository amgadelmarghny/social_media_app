import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icon_broken/icon_broken.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:social_media_app/models/user_model.dart';
import 'package:social_media_app/modules/edit_profile/edit_profile_view.dart';
import 'package:social_media_app/modules/feeds/widgets/upload_post_demo_widget.dart';
import 'package:social_media_app/modules/my_account/widgets/custom_cover_and_image_profile.dart';
import 'package:social_media_app/shared/bloc/user_cubit/user_cubit.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import 'package:social_media_app/shared/components/constants.dart';
import 'package:social_media_app/shared/components/custom_refresh_indicator.dart';
import 'package:social_media_app/shared/components/post_item.dart';
import 'package:social_media_app/shared/components/show_toast.dart';
import 'package:social_media_app/shared/network/local/cache_helper.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';
import '../../shared/style/theme/constant.dart';
import 'widgets/custom_follower_following_row.dart';

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
                  socialCubit.userModel = null;
                  await socialCubit.getUserData(
                      userUid: CacheHelper.getData(key: kUidToken));
                  socialCubit.getMyUserPosts(kUidToken);
                },
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    // Cover and profile image section
                    SliverToBoxAdapter(
                      child: Skeletonizer(
                        enabled: socialCubit.userModel == null,
                        child: CustomCoverAndImageProfile(
                          profileImage: socialCubit.userModel?.photo,
                          profileCover: socialCubit.userModel?.cover,
                          isUsedInMyAccount: true,
                        ),
                      ),
                    ),
                    // Name and edit profile button row
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Skeletonizer(
                              enabled: socialCubit.userModel == null,
                              child: Flexible(
                                child: Text(
                                  '${socialCubit.userModel?.firstName} ${socialCubit.userModel?.lastName}',
                                  style: FontsStyle.font20BoldWithColor,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                // Navigate to the edit profile view when edit button is pressed.
                                Navigator.pushNamed(
                                    context, EditProfileView.routeViewName);
                              },
                              icon: const Icon(
                                IconBroken.Edit_Square,
                                size: 32,
                                color: defaultTextColor,
                              ),
                              color: defaultTextColor,
                            )
                          ],
                        ),
                      ),
                    ),
                    // Stats row (posts, followers, following), follow/message buttons, and bio
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            // Row showing number of posts, followers, and following
                            CustomPostFollowersFollowingRow(
                              numOfPosts:
                                  socialCubit.postsModelList.length.toString(),
                              numOfFollowers:
                                  socialCubit.numberOfFollowers.toString(),
                              numOfFollowing:
                                  socialCubit.numberOfFollowing.toString(),
                              following: socialCubit.followings,
                              followers: socialCubit.followers,
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            // Show bio if it exists
                            if (socialCubit.userModel?.bio != null)
                              Text(
                                '"${socialCubit.userModel!.bio}"',
                                style: FontsStyle.font20Poppins,
                              ),
                            if (socialCubit.userModel?.bio != null)
                              const SizedBox(
                                height: 15,
                              ),
                          ],
                        ),
                      ),
                    ),
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
                    SliverList.builder(
                      itemCount: socialCubit.postsModelList.length,

                      // gridDelegate:
                      //     const SliverGridDelegateWithFixedCrossAxisCount(
                      //   childAspectRatio: 0.95,
                      //   crossAxisSpacing: 8,
                      //   mainAxisSpacing: 8,
                      //   crossAxisCount: 2,
                      // ),
                      itemBuilder: (context, index) {
                        // Placeholder image for each grid item
                        return Skeletonizer(
                          enabled: state is GetMyDataLoadingState,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: PostItem(
                              postModel: socialCubit.postsModelList[index],
                              postId: socialCubit.postsIdList[index],
                            ),
                          ),
                        );
                      },
                    ),
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
