import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:popover/popover.dart';
import 'package:social_media_app/modules/user/user_view.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import '../../../shared/components/profile_picture_with_story.dart';
import '../../../shared/style/fonts/font_style.dart';
import 'delete_post_option.dart';
import 'report_post_option.dart';

class ProfilePostRow extends StatelessWidget {
  const ProfilePostRow({
    super.key,
    required this.image,
    required this.userName,
    this.timePosted,
    this.userUid,
    this.postId,
    this.isItDeletedThroughPostView = false,
  });
  final String? image;
  final String userName;
  final String? timePosted, userUid, postId;
  final bool isItDeletedThroughPostView;

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
            timePosted != null)
          IconButton(
            onPressed: () {
              showPopover(
                direction: PopoverDirection.top,
                context: context,
                height: 50,
                width: 250,
                backgroundColor: const Color(0xff8862D9),
                bodyBuilder: (context) => userUid ==
                        BlocProvider.of<SocialCubit>(context).userModel!.uid
                    ? DeletePostOption(
                        postId: postId!,
                        isItDeletedThroughPostView: isItDeletedThroughPostView,
                      )
                    : ReportPostOption(postId: postId! , isItDeletedThroughPostView: isItDeletedThroughPostView,),
              );
            },
            icon: const Icon(Icons.more_vert),
          ),
      ],
    );
  }
}
