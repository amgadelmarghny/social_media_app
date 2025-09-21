import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:social_media_app/models/user_model.dart';
import 'package:social_media_app/modules/feeds/widgets/upload_post_demo_widget.dart';
import 'package:social_media_app/modules/feeds/widgets/user_suggestion_item.dart';
import 'package:social_media_app/modules/user/user_view.dart';
import 'package:social_media_app/shared/components/constants.dart';
import 'package:social_media_app/shared/components/custom_refresh_indicator.dart';
import 'package:social_media_app/shared/components/post_item.dart';
import 'package:social_media_app/modules/feeds/widgets/story_list_view.dart';
import 'package:social_media_app/shared/components/show_toast.dart';
import 'package:social_media_app/shared/network/local/cache_helper.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';
import 'package:social_media_app/shared/style/theme/constant.dart';
import '../../shared/bloc/social_cubit/social_cubit.dart';

class FeedsBody extends StatefulWidget {
  const FeedsBody({super.key});

  @override
  State<FeedsBody> createState() => _FeedsBodyState();
}

class _FeedsBodyState extends State<FeedsBody> {
  final ScrollController _scrollController = ScrollController();
  double _bodiesBottomPadding = 36;

  List<UserModel> searchResults = [];
  bool isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();

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

  void onSearchChanged(String value) async {
    if (value.trim().isEmpty) {
      if (mounted) {
        setState(() {
          searchResults = [];
          isSearching = false;
        });
      }
      return;
    }

    final users =
        await BlocProvider.of<SocialCubit>(context).searchUsers(value);

    if (mounted) {
      setState(() {
        searchResults = users ?? [];
        isSearching = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Future<void> handleRefresh() async {
      await BlocProvider.of<SocialCubit>(context).getTimelinePosts();
      if (context.mounted) {
        await BlocProvider.of<SocialCubit>(context)
            .getUserData(userUid: CacheHelper.getData(key: kUidToken));
      }
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
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
        padding: EdgeInsets.only(
          top: 10,
          left: 20,
          right: 20,
          bottom: _bodiesBottomPadding,
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
            if (state is SearchUsersFailureState) {
              showToast(msg: state.errMessage, toastState: ToastState.error);
            }
          },
          builder: (BuildContext context, SocialState state) {
            SocialCubit socialCubit = BlocProvider.of<SocialCubit>(context);

            return Stack(
              children: [
                /// Main Feed
                Skeletonizer(
                  enabled: socialCubit.userModel == null,
                  child: CustomRefreshIndicator(
                    onRefresh: handleRefresh,
                    child: CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        SliverToBoxAdapter(
                          child: SearchBar(
                            textStyle: WidgetStateProperty.all(
                              TextStyle(color: Colors.white), // ← لون النص
                            ),
                            // هنا التحكم في مؤشر الكتابة
                            textInputAction: TextInputAction.search,
                            hintText: 'Explore',
                            onChanged: onSearchChanged,
                            controller: _searchController,
                            leading: Padding(
                              padding: EdgeInsets.only(left: 5),
                              child: state is SearchUsersLoadingState
                                  ? SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Icon(
                                      HugeIcons.strokeRoundedSearch01,
                                      size: 32,
                                      color: Colors.white,
                                    ),
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 15),
                        ),
                        const SliverToBoxAdapter(child: StoryListView()),
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 20),
                        ),
                        if (socialCubit.postContentController.text.isNotEmpty ||
                            socialCubit.postImagePicked != null)
                          if (state is CreatePostLoadingState ||
                              state is UploadPostImageFailureState ||
                              state is CreatePostFailureState)
                            const SliverToBoxAdapter(child: UploadPostDemo()),
                        SliverList.builder(
                          itemBuilder: (context, index) {
                            return Skeletonizer(
                              enabled: state is GetFeedsPostsLoadingState,
                              child: PostItem(
                                postModel:
                                    socialCubit.freindsPostsModelList[index],
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
                ),
                if (searchResults.isNotEmpty)

                  /// Dropdown suggestions
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 65, // تحت السيرش بار بشوية
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      height: isSearching && searchResults.isNotEmpty
                          ? (searchResults.length * 80).toDouble().clamp(0, 300)
                          : 0,
                      child: Material(
                        elevation: 6,
                        color: defaultColor,
                        borderRadius: BorderRadius.circular(12),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: searchResults.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () async {
                                // روح لصفحة البروفايل
                                await Navigator.pushNamed(
                                  context,
                                  UserView.routName,
                                  arguments: searchResults[index],
                                );

                                // بعد ما يرجع
                                if (mounted) {
                                  setState(() {
                                    searchResults.clear(); // فضي الليستة
                                    isSearching =
                                        false; // عشان يخفي AnimatedContainer
                                    _searchController.clear(); // فضي السيرش بار
                                  });
                                  FocusScope.of(context)
                                      .unfocus(); // اقفل الكيبورد
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
