import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/models/message_model.dart';
import 'package:social_media_app/modules/chat/widgets/chat_view_interactive.dart';
import 'package:social_media_app/modules/chat/widgets/friend_bubble_chat.dart';
import 'package:social_media_app/modules/chat/widgets/my_bubble_chat.dart';
import 'package:social_media_app/shared/bloc/chat_cubit/chat_cubit.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import 'package:social_media_app/shared/components/message_date_lable.dart';
import 'package:social_media_app/shared/style/theme/constant.dart';

/// The main body widget for the chat view.
/// Displays the list of messages and the input area for sending new messages.
class ChatViewBody extends StatelessWidget {
  const ChatViewBody({super.key, required this.friendUid});
  final String friendUid;

  @override
  Widget build(BuildContext context) {
    // Fetch messages for the current chat with the friend
    BlocProvider.of<ChatCubit>(context).getMessages(friendUid: friendUid);

    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        // Access the ChatCubit to get the list of messages
        ChatCubit cubit = BlocProvider.of<ChatCubit>(context);
        List<MessageModel> messageList = cubit.messageList;

        return Column(
          children: [
            // Expanded widget to make the message list take available space
            Expanded(
              child: ListView.builder(
                physics: BouncingScrollPhysics(), // Adds a bounce effect
                reverse: true, // Show newest messages at the bottom
                itemCount: messageList.length,
                itemBuilder: (context, index) {
                  final message = messageList[index];
                  final currentUserId =
                      BlocProvider.of<SocialCubit>(context).userModel!.uid;

                  // لو دي أول رسالة في اليوم بتاعها → أظهر التاريخ كـ Label
                  bool showHeader = false;
                  String? headerLabel;

                  if (index == messageList.length - 1) {
                    // أول رسالة في الليست
                    showHeader = true;
                    headerLabel = getMessageDateLabel(message.dateTime);
                  } else {
                    // قارن مع الرسالة اللي بعدها
                    DateTime currentMsgDay = DateTime(message.dateTime.year,
                        message.dateTime.month, message.dateTime.day);
                    DateTime nextMsgDay = DateTime(
                        messageList[index + 1].dateTime.year,
                        messageList[index + 1].dateTime.month,
                        messageList[index + 1].dateTime.day);

                    if (currentMsgDay != nextMsgDay) {
                      showHeader = true;
                      headerLabel = getMessageDateLabel(message.dateTime);
                    }
                  }

                  return Column(
                    children: [
                      if (showHeader)
                        Container(
                          decoration: BoxDecoration(
                            color: defaultColorButton,
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 8),
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 8),
                          child: Text(
                            headerLabel!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white54,
                            ),
                          ),
                        ),

                      // الرسالة نفسها
                      if (message.uid == currentUserId)
                        MyBubbleChat(
                          message: message.message,
                          dateTime: message.dateTime,
                        )
                      else
                        FriendBubbleMessage(
                          message: message.message,
                          dateTime: message.dateTime,
                        ),
                    ],
                  );
                },
              ),
            ),
            // Widget for the chat input area (sending messages, etc.)
            ChatViewInteracrive(
              friendUid: friendUid,
            ),
          ],
        );
      },
    );
  }
}
