import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:social_media_app/models/chat_item_model.dart';
import 'package:social_media_app/models/user_model.dart';
import 'package:social_media_app/modules/chat/chat_view.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import 'package:social_media_app/shared/components/message_date_lable.dart';
import 'package:social_media_app/shared/components/profile_picture_with_story.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';

class ChatItem extends StatefulWidget {
  const ChatItem({super.key, required this.chatItemModel});
  final ChatItemModel chatItemModel;

  @override
  State<ChatItem> createState() => _ChatItemState();
}

class _ChatItemState extends State<ChatItem> {
  UserModel? userModel;
  late SocialCubit socialCubit;

  @override
  void initState() {
    socialCubit = context.read<SocialCubit>();
    getChatUserModel();
    super.initState();
  }

  Future<void> getChatUserModel() async {
    userModel =
        await socialCubit.getUserData(userUid: widget.chatItemModel.uid);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: userModel?.firstName.isEmpty ?? true,
      child: InkWell(
          onTap: () => Navigator.pushNamed(
                context,
                ChatView.routeName,
                arguments: userModel,
              ),
          child: Row(
            children: [
              ProfilePictureWithStory(
                size: 70,
                image: userModel?.photo,
                isWithoutStory: true,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${userModel?.firstName} ${userModel?.lastName}",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: FontsStyle.font20Poppins
                          .copyWith(color: Colors.white),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.chatItemModel.message,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: FontsStyle.font18PopinWithShadowOption(
                                color: Colors.white60),
                          ),
                        ),
                        Text(
                          getMessageDateLabel(widget.chatItemModel.dateTime),
                          style: FontsStyle.font18PopinWithShadowOption(
                              color: Colors.white60),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          )),
    );
  }
}
