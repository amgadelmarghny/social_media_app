import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:social_media_app/modules/feeds/widgets/upload_post_demo_widget.dart';
import 'package:social_media_app/shared/components/constants.dart';
import 'package:social_media_app/shared/components/custom_refresh_indicator.dart';
import 'package:social_media_app/shared/components/post_item.dart';
import 'package:social_media_app/modules/feeds/widgets/story_list_view.dart';
import 'package:social_media_app/shared/components/show_toast.dart';
import 'package:social_media_app/shared/network/local/cache_helper.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';
import '../../shared/bloc/social_cubit/social_cubit.dart';

class FeedsBody extends StatefulWidget {
  const FeedsBody({super.key});

  @override
  State<FeedsBody> createState() => _FeedsBodyState();
}

class _FeedsBodyState extends State<FeedsBody> {
  // Controller for handling scroll events in the feeds body.
  final ScrollController _scrollController = ScrollController();

  // Padding at the bottom of the feeds body, adjusted based on scroll.
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
    /// Handles pull-to-refresh action.
    /// Refreshes posts and user data.
    Future<void> handleRefresh() async {
      await BlocProvider.of<SocialCubit>(context).getTimelinePosts();
      if (context.mounted) {
        await BlocProvider.of<SocialCubit>(context)
            .getUserData(userUid: CacheHelper.getData(key: kUidToken));
      }
    }

    return NotificationListener<ScrollNotification>(
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
      child: Padding(
        padding: EdgeInsets.only(
          top: 10,
          left: 20,
          right: 20,
          bottom: _bodiesBottomPadding, // Dynamic bottom padding
        ),
        child: BlocConsumer<SocialCubit, SocialState>(
          listener: (BuildContext context, SocialState state) {
            if (state is CreatePostSuccessState) {
              BlocProvider.of<SocialCubit>(context).cancelPostDuringCreating();
              showToast(
                  msg: 'Post added successfully',
                  toastState: ToastState.success);
            }
            if (state is UploadPostImageFailureState) {
              showToast(msg: state.errMessage, toastState: ToastState.error);
            }
            if (state is LikePostFailureState) {
              showToast(msg: state.errMessage, toastState: ToastState.error);
            }
            if (state is CreatePostFailureState) {
              showToast(msg: state.errMessage, toastState: ToastState.error);
            }
          },
          builder: (BuildContext context, SocialState state) {
            SocialCubit socialCubit = BlocProvider.of<SocialCubit>(context);
            return Skeletonizer(
              enabled: socialCubit.userModel == null,
              child: CustomRefreshIndicator(
                onRefresh: handleRefresh,
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: SearchBar(
                        hintText: 'Explore',
                        leading: IconButton(
                          onPressed: () {},
                          icon: Icon(
                            HugeIcons.strokeRoundedSearch01,
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(
                        height: 15,
                      ),
                    ),
                    const SliverToBoxAdapter(child: StoryListView()),
                    const SliverToBoxAdapter(
                      child: SizedBox(
                        height: 20,
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
                    // post
                    SliverList.builder(
                      itemBuilder: (context, index) {
                        return Skeletonizer(
                          enabled: state is GetFeedsPostsLoadingState,
                          child: PostItem(
                            postModel: socialCubit.freindsPostsModelList[index],
                            postId: socialCubit.freindsPostsIdList[index],
                          ),
                        );
                      },
                      itemCount: socialCubit.freindsPostsModelList.length,
                    ),

                    if (socialCubit.freindsPostsModelList.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: MediaQuery.sizeOf(context).height / 5),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Follow some friends or share your first post ✨',
                              textAlign: TextAlign.center,
                              style: FontsStyle.font20Poppins,
                            ),
                          ),
                        ),
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
