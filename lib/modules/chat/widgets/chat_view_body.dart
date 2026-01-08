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
class ChatViewBody extends StatefulWidget {
  const ChatViewBody(
      {super.key, required this.friendUid, required this.friendToken});
  final String friendUid, friendToken;

  @override
  State<ChatViewBody> createState() => _ChatViewBodyState();
}

class _ChatViewBodyState extends State<ChatViewBody> {
  @override
  void initState() {
    super.initState();
    // Fetch messages for the current chat with the friend
    BlocProvider.of<ChatCubit>(context)
        .getMessages(friendUid: widget.friendUid);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Expanded widget to make the message list take available space
        Expanded(
          child: BlocBuilder<ChatCubit, ChatState>(
              buildWhen: (previous, current) =>
                  current is GetMessagesSuccess ||
                  current is GetMessagesLoading,
              builder: (context, state) {
                // Access the ChatCubit to get the list of messages
                List<MessageModel> messages = [];
                if (state is GetMessagesSuccess) {
                  messages = state.messages;
                } else {
                  // في حالة التحميل المبدئي أو الـ fallback، نأخذها من الكيوبيت
                  messages = BlocProvider.of<ChatCubit>(context).messageList;
                }
                return ListView.builder(
                  physics:
                      const BouncingScrollPhysics(), // Adds a bounce effect to the list
                  reverse: true, // Show newest messages at the bottom
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    // Get the current user's UID to distinguish between sent and received messages
                    final currentUserId =
                        BlocProvider.of<SocialCubit>(context).userModel!.uid;

                    // Determine if this message should display a date header
                    // (i.e., it's the first message of a new day)
                    // Since reverse: true, list is [oldest, ..., newest] displayed bottom-to-top
                    bool showHeader = false;
                    //!  String? headerLabel;

                    // 1. هل هذه أقدم رسالة (أعلى الشاشة)؟
                    if (index == messages.length - 1) {
                      showHeader = true;
                    } else {
                      // 2. نقارن الرسالة الحالية بالرسالة "التالية" في الـ List
                      // (التي هي أقدم منها زمنياً وتظهر فوقها)
                      final prevMessage = messages[index + 1];
                      if (message.dateTime.day != prevMessage.dateTime.day) {
                        showHeader = true;
                      }
                    }
                    // if (index == 0) {
                    //   // This is the first message in the list (oldest message) - always show header
                    //   showHeader = true;
                    //   headerLabel = getMessageDateLabel(message.dateTime);
                    // } else {
                    //   // Compare the date of this message with the previous one (older message)
                    //   DateTime currentMsgDay = DateTime(
                    //     message.dateTime.year,
                    //     message.dateTime.month,
                    //     message.dateTime.day,
                    //   );
                    //   DateTime previousMsgDay = DateTime(
                    //     messages[index - 1].dateTime.year,
                    //     messages[index - 1].dateTime.month,
                    //     messages[index - 1].dateTime.day,
                    //   );

                    //   // If the day changes between the previous message and this one, show the header
                    //   if (currentMsgDay != previousMsgDay) {
                    //     showHeader = true;
                    //     headerLabel = getMessageDateLabel(message.dateTime);
                    //   }
                    // }

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
                              message.dateTime.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white54,
                              ),
                            ),
                          ),

                        // Show the message bubble: MyBubbleChat if sent by current user, otherwise FriendBubbleMessage
                        // لكن داخل الـ Column الترتيب طبيعي، لذا نضع التاريخ "فوق" الرسالة
                        // if (showHeader)
                        //   Center(
                        //     child: Padding(
                        //       padding: const EdgeInsets.symmetric(vertical: 10),
                        //       child: MessageDateLabel(
                        //           date: message
                        //               .dateTime), // تأكد من استدعاء الويدجت الصحيح
                        //     ),
                        //   ),

                        if (message.uid == currentUserId)
                          MyBubbleChat(
                              message: message.message,
                              dateTime: message.dateTime)
                        else
                          FriendBubbleMessage(
                              message: message.message,
                              dateTime: message.dateTime),
                      ],
                    );
                  },
                );
              }),
        ),
        // Widget for the chat input area (sending messages, etc.)
        ChatViewInteracrive(
          friendUid: widget.friendUid,
          friendToken: widget.friendToken,
        ),
        
      ],
    );
  }
}
