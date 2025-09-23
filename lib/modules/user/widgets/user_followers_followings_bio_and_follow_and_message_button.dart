import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:social_media_app/models/user_model.dart';
import 'package:social_media_app/modules/my_account/widgets/custom_follower_following_row.dart';
import 'package:social_media_app/modules/my_account/widgets/follow_and_message_buttons.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import 'package:social_media_app/shared/bloc/user_cubit/user_cubit.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';

class UserFollowersFollowingsBioAndFollowAndMessageButton
    extends StatelessWidget {
  const UserFollowersFollowingsBioAndFollowAndMessageButton({
    super.key,
    required this.userModel,
  });
  final UserModel userModel;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: BlocBuilder<UserCubit, UserState>(
          builder: (context, state) {
            UserCubit userCubit = context.read<UserCubit>();
            return Column(
              children: [
                // Row showing number of posts, followers, and following
                Skeletonizer(
                  enabled: state is GetUserFollowersLoadingState &&
                      state is GetUserFollowingLoadingState,
                  child: CustomPostFollowersFollowingRow(
                    numOfPosts: userCubit.postsModelList.length.toString(),
                    numOfFollowers: userCubit.numberOfFollowers.toString(),
                    numOfFollowing: userCubit.numberOfFollowing.toString(),
                    following: userCubit.followings,
                    followers: userCubit.followers,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),

                if (context.read<SocialCubit>().userModel!.uid != userModel.uid)
                  FollowAndMessageButtons(
                    userModel: userModel,
                  ),
                const SizedBox(
                  height: 15,
                ),
                // Show bio if it exists
                if (userModel.bio != null)
                  Skeletonizer(
                    enabled: userModel.bio == null,
                    child: Text(
                      '"${userModel.bio}"',
                      style: FontsStyle.font20Poppins,
                    ),
                  ),
                if (userModel.bio != null)
                  const SizedBox(
                    height: 15,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
