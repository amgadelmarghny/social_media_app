import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/models/user_model.dart';
import 'package:social_media_app/modules/user/widgets/user_followers_followings_bio_and_follow_and_message_button.dart';
import 'package:social_media_app/modules/user/widgets/user_profile_and_cover_image_section.dart';
import 'package:social_media_app/modules/user/widgets/user_sliver_posts_list_builder.dart';
import 'package:social_media_app/shared/bloc/user_cubit/user_cubit.dart';
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
        if (state is GetUserFollowingErrorState) {
          showToast(msg: state.errMessage, toastState: ToastState.error);
        }
        if (state is GetUserFollowersFailureState) {
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
              UserProfileAndCoverImageSection(
                profileCover: userModel.cover,
                profileImage: userModel.photo,
                uid: userModel.uid,
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
              UserFollowersFollowingsBioAndFollowAndMessageButton(
                  userModel: userModel),
              //user's posts
             const UserSliverPostsListBuilder()
            ],
          ),
        );
      },
    );
  }
}

     // SliverGrid.builder(
              //   itemCount: userCubit.postsModelList.length,
              //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              //     childAspectRatio: 0.95,
              //     crossAxisSpacing: 8,
              //     mainAxisSpacing: 8,
              //     crossAxisCount: 2,
              //   ),
              //   itemBuilder: (context, index) {
              //     // Placeholder image for each grid item
              //     return PostItem(
              //       postModel: userCubit.postsModelList[index],
              //       postId: userCubit.postsIdList[index],
              //     );
              //   },
              // ),