import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:social_media_app/modules/my_account/widgets/custom_follower_following_row.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';

class MyFollowersAndFollowindAndBioAccount extends StatelessWidget {
  const MyFollowersAndFollowindAndBioAccount({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: BlocBuilder<SocialCubit, SocialState>(
          builder: (context, state) {
            SocialCubit socialCubit = context.read<SocialCubit>();
            return Skeletonizer(
              enabled: socialCubit.userModel== null,
              child: Column(
                children: [
                  // Row showing number of posts, followers, and following
                  CustomPostFollowersFollowingRow(
                    numOfPosts: socialCubit.postsModelList.length.toString(),
                    numOfFollowers: socialCubit.numberOfFollowers.toString(),
                    numOfFollowing: socialCubit.numberOfFollowing.toString(),
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
            );
          },
        ),
      ),
    );
  }
}