import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/models/message_model.dart';
import 'package:social_media_app/modules/chat/widgets/chat_view_interactive.dart';
import 'package:social_media_app/modules/chat/widgets/friend_bubble_chat.dart';
import 'package:social_media_app/modules/chat/widgets/friend_voice_message.dart';
import 'package:social_media_app/modules/chat/widgets/my_bubble_chat.dart';
import 'package:social_media_app/modules/chat/widgets/my_voice_message_widget.dart';
import 'package:social_media_app/shared/bloc/chat_cubit/chat_cubit.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import 'package:social_media_app/shared/components/message_date_lable.dart';
import 'package:social_media_app/shared/style/theme/constant.dart';

/// The main body widget for the chat view.
/// Displays the list of messages and the input area for sending new messages.
class ChatViewBody extends StatefulWidget {
  /// [friendUid]: The UID of the friend to chat with.
  /// [friendToken]: The notification token for the friend, used for FCM/etc.
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
    // Fetch messages for the current chat with the friend when widget initializes.
    BlocProvider.of<ChatCubit>(context)
        .getMessages(friendUid: widget.friendUid);
  }

  @override
  Widget build(BuildContext context) {
    // Main Column holds the chat messages above and the chat input below.
    return Column(
      children: [
        // Expanded widget to allow the chat message list to take all available space,
        // while the input widget stays at the bottom.
        Expanded(
          child: BlocBuilder<ChatCubit, ChatState>(
              // Re-build only when messages are loaded or loading anew.
              buildWhen: (previous, current) =>
                  current is GetMessagesSuccess ||
                  current is GetMessagesLoading,
              builder: (context, state) {
                // List to hold messages for chat
                List<MessageModel> messages = [];
                if (state is GetMessagesSuccess) {
                  // Use messages loaded in the successful state
                  messages = state.messages;
                } else {
                  // Otherwise, use messages cached in the cubit
                  // (e.g., during loading or as a fallback)
                  messages = BlocProvider.of<ChatCubit>(context).messageList;
                }
                return ListView.builder(
                  physics:
                      const BouncingScrollPhysics(), // Enables iOS-style bounce
                  reverse:
                      true, // Shows newest messages at the bottom, old at top
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];

                    // Identify the current user id to distinguish own messages from friend's
                    final currentUserId =
                        BlocProvider.of<SocialCubit>(context).userModel!.uid;

                    // Flag to determine whether to show a header label for message date
                    bool showHeader = false;

                    // If this is the oldest message (at the top), always show header
                    if (index == messages.length - 1) {
                      showHeader = true;
                    } else {
                      // Otherwise, compare to the previous (older) message and show
                      // the header if the date changes.
                      final prevMessage = messages[index + 1];
                      if (message.dateTime.day != prevMessage.dateTime.day) {
                        showHeader = true;
                      }
                    }
                    // Build the message bubble (with possible date header above)
                    return Column(
                      children: [
                        // Show a date header label if it's the first message of a new day
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
                              // Utility method to get human-readable date label
                              getMessageDateLabel(message.dateTime),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white54,
                              ),
                            ),
                          ),

                        Builder(builder: (context) {
                          // Display message bubble as "MyBubbleChat" if sent by user,
                          // otherwise as friend bubble chat component.
                          if (message.uid == currentUserId) {
                            if (message.message != null) {
                              return MyBubbleChat(
                                  message: message.message!,
                                  dateTime: message.dateTime);
                            } else if (message.voiceRecord != null) {
                              return MyVoiceMessageWidget(
                                key: ValueKey(message.voiceRecord),
                                audioUrl: message.voiceRecord!,
                                dateTime: message.dateTime,
                              );
                            }
                          } else {
                            if (message.message != null) {
                              return FriendBubbleMessage(
                                  message: message.message!,
                                  dateTime: message.dateTime);
                            } else {
                              return FriendVoiceMessageWidget(
                                key: ValueKey(message.voiceRecord),
                                audioUrl: message.voiceRecord!,
                                dateTime: message.dateTime,
                              );
                            }
                          }
                          return SizedBox();
                        })
                      ],
                    );
                  },
                );
              }),
        ),
        // Widget for the chat input area (sending messages, etc.)
        // Always stays fixed to the bottom of the screen under the message list.
        ChatViewInteracrive(
          friendUid: widget.friendUid,
          friendToken: widget.friendToken,
        ),
      ],
    );
  }
}
