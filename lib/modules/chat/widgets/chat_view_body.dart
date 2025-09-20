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
                physics: const BouncingScrollPhysics(), // Adds a bounce effect to the list
                reverse: true, // Show newest messages at the bottom
                itemCount: messageList.length,
                itemBuilder: (context, index) {
                  final message = messageList[index];
                  // Get the current user's UID to distinguish between sent and received messages
                  final currentUserId =
                      BlocProvider.of<SocialCubit>(context).userModel!.uid;

                  // Determine if this message should display a date header
                  // (i.e., it's the first message of a new day)
                  bool showHeader = false;
                  String? headerLabel;

                  if (index == messageList.length - 1) {
                    // This is the last message in the list (oldest message)
                    showHeader = true;
                    headerLabel = getMessageDateLabel(message.dateTime);
                  } else {
                    // Compare the date of this message with the next one
                    DateTime currentMsgDay = DateTime(
                      message.dateTime.year,
                      message.dateTime.month,
                      message.dateTime.day,
                    );
                    DateTime nextMsgDay = DateTime(
                      messageList[index + 1].dateTime.year,
                      messageList[index + 1].dateTime.month,
                      messageList[index + 1].dateTime.day,
                    );

                    // If the day changes between this message and the next, show the header
                    if (currentMsgDay != nextMsgDay) {
                      showHeader = true;
                      headerLabel = getMessageDateLabel(message.dateTime);
                    }
                  }

                  return Column(
                    children: [
                      // Show the date header if needed
                      if (showHeader)
                        Container(
                          decoration: const BoxDecoration(
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
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white54,
                            ),
                          ),
                        ),

                      // Show the message bubble: MyBubbleChat if sent by current user, otherwise FriendBubbleMessage
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
