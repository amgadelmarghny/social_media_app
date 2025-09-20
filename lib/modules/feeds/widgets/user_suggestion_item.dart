import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/models/user_model.dart';
import 'package:social_media_app/modules/user/user_view.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import 'package:social_media_app/shared/bloc/user_cubit/user_cubit.dart';
import 'package:social_media_app/shared/components/constants.dart';
import 'package:social_media_app/shared/components/custom_button.dart';
import 'package:social_media_app/shared/components/profile_picture_with_story.dart';
import 'package:social_media_app/shared/network/local/cache_helper.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';

class UserSuggestionItem extends StatelessWidget {
  const UserSuggestionItem({super.key, required this.userModel});
  final UserModel userModel;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                UserView.routName,
                arguments: userModel,
              );
            },
            child: Row(
              children: [
                ProfilePictureWithStory(
                  image: userModel.photo,
                  size: 70,
                ),
                SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: Text(
                    "${userModel.firstName} ${userModel.lastName}",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: FontsStyle.font18PopinMedium(),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (userModel.uid != CacheHelper.getData(key: kUidToken))
          BlocBuilder<UserCubit, UserState>(
            builder: (context, state) {
              final userCubit = context.read<UserCubit>();
              final isFollowing = userCubit.isFollowing;
              SocialCubit socialCubit = context.read<SocialCubit>();

              return CustomButton(
                height: 40,
                fontSize: 18,
                width: 100,
                text: isFollowing ? "Unfollow" : "Follow",
                onTap: () async {
                  if (isFollowing) {
                    await userCubit.unfollowUser(
                        socialCubit.userModel!.uid, userModel.uid);
                  } else {
                    await userCubit.followUser(
                        socialCubit.userModel!.uid, userModel.uid);
                  }
                  userCubit.getFollowers(userModel.uid);
                  socialCubit.getFollowing();
                },
              );
            },
          )
      ],
    );
  }
}
