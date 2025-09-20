import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/models/user_model.dart';
import 'package:social_media_app/modules/chat/chat_view.dart';
import 'package:social_media_app/shared/bloc/user_cubit/user_cubit.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import '../../../shared/components/custom_button.dart';

class FollowAndMessageButtons extends StatelessWidget {
  const FollowAndMessageButtons({
    super.key,
    required this.userModel,
  });

  final UserModel userModel;

  @override
  Widget build(BuildContext context) {
    String uid = context.read<SocialCubit>().userModel!.uid;

    return Row(
      children: [
        BlocBuilder<UserCubit, UserState>(
          builder: (context, state) {
            final userCubit = context.read<UserCubit>();
            final isFollowing = userCubit.isFollowing;

            return Expanded(
              child: CustomButton(
                height: 50,
                text: isFollowing ? "Unfollow" : "Follow",
                onTap: () async {
                  if (isFollowing) {
                    await userCubit.unfollowUser(uid, userModel.uid);
                  } else {
                    await userCubit.followUser(uid, userModel.uid);
                  }
                  userCubit.getFollowers(userModel.uid);
                  if (context.mounted) {
                    context.read<SocialCubit>().getFollowing();
                  }
                },
              ),
            );
          },
        ),
        const SizedBox(width: 20),
        Expanded(
          child: CustomButton(
            text: 'Message',
            height: 50,
            buttonColor: Colors.white,
            textColor: const Color(0xFF635A8F),
            onTap: () => Navigator.pushNamed(
              context,
              ChatView.routeName,
              arguments: userModel,
            ),
          ),
        ),
      ],
    );
  }
}
