import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:social_media_app/models/message_model.dart';
import 'package:social_media_app/modules/chat/widgets/chat_view_interactive.dart';
import 'package:social_media_app/modules/chat/widgets/custom_picked_images_list_view.dart';
import 'package:social_media_app/modules/chat/widgets/friend_bubble_chat.dart';
import 'package:social_media_app/modules/chat/widgets/friend_photos_with_text_message_bubble_chat.dart';
import 'package:social_media_app/modules/chat/widgets/friend_voice_message.dart';
import 'package:social_media_app/modules/chat/widgets/my_bubble_chat.dart';
import 'package:social_media_app/modules/chat/widgets/my_photos_with_text_message_bubble_chat.dart';
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
  // Flag to track if the initial entrance animation has already been performed.
  // This prevents the entire list from re-animating every time a new message is sent/received.
  bool _isInitialAnimationDone = false;

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
          child: BlocConsumer<ChatCubit, ChatState>(
            // Re-build only when messages are loaded or loading anew.
            buildWhen: (previous, current) =>
                current is GetMessagesSuccess || current is GetMessagesLoading,
            listener: (context, state) {
              // Once we get the first successful batch of messages that isn't empty,
              // schedule the flag to be set to true AFTER this frame has rendered.
              // This ensures the first load actually PERFORMS the animation.
              if (state is GetMessagesSuccess &&
                  state.messages.isNotEmpty &&
                  !_isInitialAnimationDone) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _isInitialAnimationDone = true;
                    });
                  }
                });
              }
            },
            builder: (context, state) {
              final chatCubit = context.read<ChatCubit>();
              bool isSending =
                  state is SendMessageLoading || state is UploadImageLoading;
              // List to hold messages for chat
              List<MessageModel> messages = [];
              if (state is GetMessagesSuccess) {
                // Use messages loaded in the successful state
                messages = state.messages;
              } else {
                // Otherwise, use messages cached in the cubit
                // (e.g., during loading or as a fallback)
                messages = chatCubit.messageList;
              }

              // We only wrap with AnimationLimiter if the initial animation isn't done.
              Widget listView = ListView.builder(
                physics: const BouncingScrollPhysics(),
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final currentUserId =
                      BlocProvider.of<SocialCubit>(context).userModel!.uid;
                  final bool isSelfChat = currentUserId == widget.friendUid;

                  bool showHeader = false;
                  if (index == messages.length - 1) {
                    showHeader = true;
                  } else {
                    final prevMessage = messages[index + 1];
                    if (message.dateTime.day != prevMessage.dateTime.day) {
                      showHeader = true;
                    }
                  }

                  // The actual message content widget
                  Widget messageWidget = Column(
                    children: [
                      if (showHeader) _buildDateHeader(message.dateTime),
                      _buildMessageBubble(
                          message, currentUserId, isSending, isSelfChat),
                    ],
                  );

                  // If initial animation is done, return widget directly without animation wrappers
                  if (_isInitialAnimationDone) {
                    return messageWidget;
                  }

                  // Otherwise, wrap with staggered and entrance animations
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: messageWidget,
                      ),
                    ),
                  );
                },
              );

              return _isInitialAnimationDone
                  ? listView
                  : AnimationLimiter(child: listView);
            },
          ),
        ),
        CustomPickedImagesListView(),
        // Widget for the chat input area (sending messages, etc.)
        // Always stays fixed to the bottom of the screen under the message list.
        ChatViewInteracrive(
          friendUid: widget.friendUid,
          friendToken: widget.friendToken,
        ),
      ],
    );
  }

  Widget _buildDateHeader(DateTime dateTime) {
    Widget header = Container(
      decoration: const BoxDecoration(
        color: defaultColorButton,
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8),
      child: Text(
        getMessageDateLabel(dateTime),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white54,
        ),
      ),
    );

    if (_isInitialAnimationDone) {
      return header;
    }
    return FadeInDown(
      duration: const Duration(milliseconds: 400),
      child: header,
    );
  }

  Widget _buildMessageBubble(MessageModel message, String currentUserId,
      bool isSending, bool isSelfChat) {
    Widget bubble;
    if (message.uid == currentUserId) {
      bubble = _buildMyMessage(message, isSending, isSelfChat);
      if (_isInitialAnimationDone) return bubble;
      return FadeInRight(
        duration: const Duration(milliseconds: 300),
        child: bubble,
      );
    } else {
      bubble = _buildFriendMessage(message);
      if (_isInitialAnimationDone) return bubble;
      return FadeInLeft(
        duration: const Duration(milliseconds: 300),
        child: bubble,
      );
    }
  }

  Widget _buildMyMessage(
      MessageModel message, bool isSending, bool isSelfChat) {
    if (message.images != null) {
      return MyPhotosWithTextMessageBubbleChat(
        message: message.textMessage,
        images: message.images!,
        dateTime: message.dateTime,
        isRead: message.isRead,
        isDelivered: message.isDelivered,
        isSending: isSending,
        isSelfChat: isSelfChat,
      );
    }
    if (message.textMessage != null) {
      return MyBubbleChat(
        message: message.textMessage!,
        dateTime: message.dateTime,
        isRead: message.isRead,
        isDelivered: message.isDelivered,
        isSending: isSending,
        isSelfChat: isSelfChat,
      );
    } else if (message.voiceRecord != null) {
      return MyVoiceMessageWidget(
        key: ValueKey(message.voiceRecord),
        audioUrl: message.voiceRecord!,
        dateTime: message.dateTime,
        isRead: message.isRead,
        isDelivered: message.isDelivered,
        isSending: isSending,
        isSelfChat: isSelfChat,
      );
    }
    return const SizedBox();
  }

  Widget _buildFriendMessage(MessageModel message) {
    if (message.images != null) {
      return FriendPhotosWithText(
          message: message.textMessage,
          images: message.images!,
          dateTime: message.dateTime);
    }
    if (message.textMessage != null) {
      return FriendBubbleMessage(
          message: message.textMessage!, dateTime: message.dateTime);
    } else if (message.voiceRecord != null) {
      return FriendVoiceMessageWidget(
        key: ValueKey(message.voiceRecord),
        audioUrl: message.voiceRecord!,
        dateTime: message.dateTime,
      );
    }
    return const SizedBox();
  }
}
