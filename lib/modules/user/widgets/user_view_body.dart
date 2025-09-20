import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/models/user_model.dart';
import 'package:social_media_app/modules/my_account/widgets/custom_cover_and_image_profile.dart';
import 'package:social_media_app/modules/my_account/widgets/custom_follower_following_row.dart';
import 'package:social_media_app/modules/my_account/widgets/follow_and_message_buttons.dart';
import 'package:social_media_app/shared/bloc/user_cubit/user_cubit.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import 'package:social_media_app/shared/components/post_item.dart';
import 'package:social_media_app/shared/components/show_toast.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';

/// The main body widget for the user's own account/profile page.
/// Displays cover, profile image, name, edit button, stats, follow/message buttons, bio, and a grid of images.
class UserViewBody extends StatelessWidget {
  const UserViewBody({super.key, required this.userModel});
  final UserModel userModel;

  @override
  Widget build(BuildContext context) {
    // Provide a FollowCubit for managing follow state.
    return BlocConsumer<UserCubit, UserState>(
      // Listen for various SocialCubit states to show toasts for errors/success.
      listener: (context, state) {
        if (state is GetUserPostsFailure) {
          showToast(msg: state.errMessage, toastState: ToastState.error);
        }
      },
      builder: (context, state) {
        UserCubit userCubit = context.read<UserCubit>();
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
          child: CustomScrollView(
            slivers: [
              // Cover and profile image section
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    CustomCoverAndImageProfile(
                      profileImage: userModel.photo,
                      profileCover: userModel.cover,
                      isUsedInMyAccount:
                          context.read<SocialCubit>().userModel!.uid ==
                              userModel.uid,
                    ),
                    Positioned(
                      top: MediaQuery.paddingOf(context).top,
                      left: 15,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back_ios),
                      ),
                    )
                  ],
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(
                  height: 15,
                ),
              ),
              // Name and edit profile button row
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    '${userModel.firstName} ${userModel.lastName}',
                    textAlign: TextAlign.center,
                    style: FontsStyle.font20BoldWithColor,
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(
                  height: 15,
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
                        numOfPosts: userCubit.postsModelList.length.toString(),
                        numOfFollowers: userCubit.numberOfFollowers.toString(),
                        numOfFollowing: userCubit.numberOfFollowing.toString(),
                        following: userCubit.followings,
                        followers: userCubit.followers,
                      ),
                      const SizedBox(
                        height: 15,
                      ),

                      if (context.read<SocialCubit>().userModel!.uid !=
                          userModel.uid)
                        FollowAndMessageButtons(
                          userModel: userModel,
                        ),
                      const SizedBox(
                        height: 15,
                      ),
                      // Show bio if it exists
                      if (userModel.bio != null)
                        Text(
                          '"${userModel.bio}"',
                          style: FontsStyle.font20Poppins,
                        ),
                      if (userModel.bio != null)
                        const SizedBox(
                          height: 15,
                        ),
                    ],
                  ),
                ),
              ),
              //user's posts
              SliverGrid.builder(
                itemCount: userCubit.postsModelList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 0.95,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  crossAxisCount: 2,
                ),
                itemBuilder: (context, index) {
                  // Placeholder image for each grid item
                  return PostItem(
                    postModel: userCubit.postsModelList[index],
                    postId: userCubit.postsIdList[index],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
