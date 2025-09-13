import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/models/message_model.dart';
import 'package:social_media_app/modules/chat/widgets/chat_view_interactive.dart';
import 'package:social_media_app/modules/chat/widgets/friend_bubble_chat.dart';
import 'package:social_media_app/modules/chat/widgets/my_bubble_chat.dart';
import 'package:social_media_app/shared/bloc/chat_cubit/chat_cubit.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';

class ChatViewBody extends StatelessWidget {
  const ChatViewBody({super.key, required this.friendUid});
  final String friendUid;

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<ChatCubit>(context).getMessages(friendUid: friendUid);
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        ChatCubit cubit = BlocProvider.of<ChatCubit>(context);
        List<MessageModel> messageList = cubit.messageList;

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                reverse: true,
                itemCount: messageList.length,
                itemBuilder: (context, index) {
                  final message = messageList[index];
                  final currentUserId =
                      BlocProvider.of<SocialCubit>(context).userModel!.uid;

                  // Check if message belongs to current user
                  if (message.uid == currentUserId) {
                    return MyBubbleChat(
                      message: message.message,
                      dateTime: message.dateTime,
                    );
                  } else {
                    return FriendBubbleMessage(
                      message: message.message,
                      dateTime: message.dateTime,
                    );
                  }
                },
              ),
            ),
            ChatViewInteracrive(
              friendUid: friendUid,
            ),
          ],
        );
      },
    );
  }
}
