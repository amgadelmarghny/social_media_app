import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:popover/popover.dart';
import 'package:social_media_app/modules/user/user_view.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import '../../../shared/components/profile_picture_with_story.dart';
import '../../../shared/style/fonts/font_style.dart';

class ProfilePostRow extends StatelessWidget {
  const ProfilePostRow({
    super.key,
    required this.image,
    required this.userName,
    this.timePosted,
    this.userUid,
    this.postId,
  });
  final String? image;
  final String userName;
  final String? timePosted, userUid, postId;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () async {
            final userModel = await BlocProvider.of<SocialCubit>(context)
                .getUserData(userUid: userUid!);
            if (context.mounted) {
              Navigator.pushNamed(context, UserView.routName,
                  arguments: userModel);
            }
          },
          child: ProfilePictureWithStory(
            image: image,
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () async {
                  final userModel = await BlocProvider.of<SocialCubit>(context)
                      .getUserData(userUid: userUid!);
                  if (context.mounted) {
                    Navigator.pushNamed(context, UserView.routName,
                        arguments: userModel);
                  }
                },
                child: Text(
                  userName,
                  style: FontsStyle.font18PopinMedium(),
                ),
              ),
              if (timePosted != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2.5),
                  child: Text(
                    timePosted!,
                    style: FontsStyle.font15Popin(
                      height: 1,
                      color: Colors.white60,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (BlocProvider.of<SocialCubit>(context).userModel != null &&
            userUid == BlocProvider.of<SocialCubit>(context).userModel!.uid &&
            timePosted != null)
          IconButton(
            onPressed: () {
              showPopover(
                direction: PopoverDirection.top,
                context: context,
                height: 50,
                width: 250,
                backgroundColor: const Color(0xff8862D9),
                bodyBuilder: (context) => GestureDetector(
                  onTap: () async {
                    if (context.mounted) Navigator.pop(context);
                    await BlocProvider.of<SocialCubit>(context)
                        .deletePost(postId!);
                  },
                  child: Container(
                    height: 50,
                    color: const Color(0xff8862D9),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          radius: 15,
                          child: const Icon(
                            HugeIcons.strokeRoundedDelete03,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          'Delete post',
                          style: FontsStyle.font18Popin(),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.more_vert),
          ),
      ],
    );
  }
}
