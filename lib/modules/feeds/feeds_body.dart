import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:social_media_app/layout/home/components/verify_email_container.dart';
import 'package:social_media_app/models/user_model.dart';
import 'package:social_media_app/modules/feeds/widgets/sliver_list_feed_items.dart';
import 'package:social_media_app/modules/feeds/widgets/upload_post_demo_widget.dart';
import 'package:social_media_app/modules/feeds/widgets/user_suggestion_item.dart';
import 'package:social_media_app/modules/user/user_view.dart';
import 'package:social_media_app/shared/components/constants.dart';
import 'package:social_media_app/shared/components/custom_refresh_indicator.dart';
import 'package:social_media_app/modules/feeds/widgets/story_list_view.dart';
import 'package:social_media_app/shared/components/show_toast.dart';
import 'package:social_media_app/shared/network/local/cache_helper.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';
import 'package:social_media_app/shared/style/theme/constant.dart';
import '../../shared/bloc/social_cubit/social_cubit.dart';

/// The main body of the feeds (timeline) screen.
/// Shows posts, search user field, stories, email verification banner, etc.
class FeedsBody extends StatefulWidget {
  const FeedsBody({super.key});

  @override
  State<FeedsBody> createState() => _FeedsBodyState();
}

class _FeedsBodyState extends State<FeedsBody> {
  // Scroll controller for the main feed list
  final ScrollController _scrollController = ScrollController();
  // Dynamic bottom padding for handling scroll
  double _bodiesBottomPadding = 36;

  // Stores search results for user search suggestions
  List<UserModel> searchResults = [];
  // If the search suggestion dropdown is open
  bool isSearching = false;
  // Controller for the search input field
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Listen for scrolling to the bottom to adjust feed padding for floating widgets/spacing
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        bool isTop = _scrollController.position.pixels == 0;
        if (!isTop) {
          setState(() {
            _bodiesBottomPadding = 82;
          });
        }
      }
    });
  }

  /// Search callback for the search field at the top of the feed
  void onSearchChanged(String value) async {
    // If the field is empty, clear suggestions dropdown & reset state
    if (value.trim().isEmpty) {
      if (mounted) {
        setState(() {
          searchResults = [];
          isSearching = false;
        });
      }
      return;
    }

    // Query users by search term using cubit
    final users =
        await BlocProvider.of<SocialCubit>(context).searchUsers(value);

    // If search result, display suggestion dropdown
    if (mounted) {
      setState(() {
        searchResults = users ?? [];
        isSearching = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pull-to-refresh logic for the entire feed ('timeline posts' and user data)
    Future<void> handleRefresh() async {
      await BlocProvider.of<SocialCubit>(context).getTimelinePosts();
      if (context.mounted) {
        await BlocProvider.of<SocialCubit>(context)
            .getUserData(userUid: CacheHelper.getData(key: kUidToken));
      }
    }

    // NotificationListener is used to dynamically change feed padding when scrolling up
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        // If user scrolls UP, reduce padding to show more feed
        if (scrollNotification is ScrollUpdateNotification) {
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
        // Main screen padding; bottom is dynamic for better UX
        padding: EdgeInsets.only(
          top: 10,
          left: 20,
          right: 20,
          bottom: _bodiesBottomPadding,
        ),
        child: BlocConsumer<SocialCubit, SocialState>(
          // Listen for side effects to show toasts, reset create post, etc.
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
            if (state is SearchUsersFailureState) {
              showToast(msg: state.errMessage, toastState: ToastState.error);
            }
          },
          builder: (BuildContext context, SocialState state) {
            // Get the current SocialCubit
            SocialCubit socialCubit = BlocProvider.of<SocialCubit>(context);

            return Stack(
              children: [
                /// Skeletonizer will show a loading skeleton if user data is null.
                /// Acts as a shimmer loading effect on initial feed load.
                Skeletonizer(
                  enabled: socialCubit.userModel == null,
                  child: CustomRefreshIndicator(
                    onRefresh: handleRefresh,
                    child: CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        // Show email verification banner if user is not verified
                        if (BlocProvider.of<SocialCubit>(context)
                                .userVerification
                                ?.emailVerified ==
                            false)
                          const SliverToBoxAdapter(
                              child: VerifyEmailContainer()),

                        /// Search bar for exploring users; triggers onSearchChanged
                        SliverToBoxAdapter(
                          child: SearchBar(
                            textStyle: WidgetStateProperty.all(
                              const TextStyle(color: Colors.white),
                            ),
                            textInputAction: TextInputAction.search,
                            hintText: 'Explore',
                            onChanged: onSearchChanged,
                            controller: _searchController,
                            leading: Padding(
                              padding: EdgeInsets.only(left: 5),
                              child: state is SearchUsersLoadingState
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      HugeIcons.strokeRoundedSearch01,
                                      size: 32,
                                      color: Colors.white,
                                    ),
                            ),
                          ),
                        ),

                        // Space below search bar
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 15),
                        ),

                        // Stories horizontally scrollable list
                        const SliverToBoxAdapter(child: StoryListView()),

                        // Space below stories
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 20),
                        ),

                        // If a new post is being composed, and there is a pending post or error/loading, show the upload preview
                        if (socialCubit.postContentController.text.isNotEmpty ||
                            socialCubit.postImagePicked != null)
                          if (state is CreatePostLoadingState ||
                              state is UploadPostImageFailureState ||
                              state is CreatePostFailureState)
                            const SliverToBoxAdapter(child: UploadPostDemo()),

                        // Main feed items (list of posts as a SliverList)
                        const SliverListfeedItems(),

                        // Show a call to action message if there are no posts from friends (feed is empty)
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
                ),

                /// Dropdown user search suggestions. Only visible when actively searching
                Positioned(
                  left: 0,
                  right: 0,
                  top: 63,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    // Height is dynamic: #suggestions * 80, clamped to max 300
                    height: isSearching && searchResults.isNotEmpty
                        ? (searchResults.length * 80).toDouble().clamp(0, 300)
                        : 0,
                    child: Material(
                      elevation: 6,
                      color: defaultColor,
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () async {
                              // Navigates to the selected user's profile view
                              await Navigator.pushNamed(
                                context,
                                UserView.routName,
                                arguments: searchResults[index],
                              );

                              // After returning from profile, clear suggestions & remove focus
                              if (mounted) {
                                setState(() {
                                  searchResults.clear();
                                  isSearching = false;
                                  _searchController.clear();
                                });
                                FocusScope.of(context).unfocus();
                              }
                            },
                            child: UserSuggestionItem(
                              userModel: searchResults[index],
                              isFromSearch: true,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
