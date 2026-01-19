import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:social_media_app/modules/chat/widgets/custom_chat_text_field.dart';
import 'package:social_media_app/modules/chat/widgets/stream_voice_record_widget.dart';
import 'package:social_media_app/modules/chat/widgets/custom_voice_record_icon.dart';
import 'package:social_media_app/shared/bloc/chat_cubit/chat_cubit.dart';
import 'package:social_media_app/shared/style/theme/constant.dart';

/// A widget that represents the interactive chat input section at the bottom of the chat view.
/// Can switch between text input and voice recording mode.
class ChatViewInteracrive extends StatelessWidget {
  /// The UID of the friend we're chatting with
  final String friendUid;

  /// The notification token of the friend (may be used for FCM, not used in this widget)
  final String friendToken;

  const ChatViewInteracrive({
    super.key,
    required this.friendUid,
    required this.friendToken,
  });

  @override
  Widget build(BuildContext context) {
    // The container provides background color and padding accommodating system bottom inset
    return Container(
      color: defaultColor,
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
        top: 10,
        bottom: MediaQuery.viewPaddingOf(context).bottom + 6,
      ),
      child: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          // Get the chat cubit from BlocProvider
          ChatCubit chatCubit = BlocProvider.of<ChatCubit>(context);
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// The leading icon button switches between image-add icon and delete icon when recording
              IconButton(
                onPressed: () async {
                  if (chatCubit.isRecording) {
                    // When recording: allow cancelling the voice recording
                    await chatCubit.cancelRecording();
                  } else {
                   await chatCubit.pickAndSendImages(friendUid: friendUid);
                  }
                },
                icon: AnimatedCrossFade(
                  // Shows the image-add icon when not recording
                  firstChild: const HugeIcon(
                    icon: HugeIcons.strokeRoundedImageAdd02,
                    color: Color(0XFFC4C2CB),
                  ),
                  // Shows the delete icon when recording (for cancelling)
                  secondChild: const HugeIcon(
                    icon: HugeIcons.strokeRoundedDelete02,
                    color: Color(0XFFC4C2CB),
                  ),
                  crossFadeState:
                      BlocProvider.of<ChatCubit>(context).isRecording
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 260),
                ),
              ),
              // The main expanding child: either a text field or the animated voice recording bar
              Expanded(
                child: AnimatedCrossFade(
                  // Text field for typing a chat message (default)
                  firstChild: CustomChatTextField(friendUid: friendUid),
                  // Voice recording animated waveform (shown while recording)
                  secondChild: const StreamVoiceWidget(),
                  crossFadeState:
                      BlocProvider.of<ChatCubit>(context).isRecording
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 260),
                ),
              ),
              // The microphone/send voice icon button; handles recording or sending voice
              CustomVoiceRecordIcon(
                friendUid: friendUid,
              ),
            ],
          );
        },
      ),
    );
  }
}
