import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:social_media_app/modules/chat/widgets/custom_chat_text_field.dart';
import 'package:social_media_app/modules/chat/widgets/stream_voice_record_widget.dart';
import 'package:social_media_app/modules/chat/widgets/custom_voice_record_icon.dart';
import 'package:social_media_app/shared/bloc/chat_cubit/chat_cubit.dart';
import 'package:social_media_app/shared/style/theme/constant.dart';

class ChatViewInteracrive extends StatelessWidget {
  const ChatViewInteracrive({
    super.key,
    required this.friendUid,
    required this.friendToken,
  });
  final String friendUid;
  final String friendToken;
  @override
  Widget build(BuildContext context) {
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
          ChatCubit chatCubit = BlocProvider.of<ChatCubit>(context);
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () async {
                  if (chatCubit.isRecording) {
                    await chatCubit.cancelRecording();
                  } else {}
                },
                icon: AnimatedCrossFade(
                  firstChild: const HugeIcon(
                    icon: HugeIcons.strokeRoundedImageAdd02,
                    color: Color(0XFFC4C2CB),
                  ),
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
              Expanded(
                child: AnimatedCrossFade(
                  firstChild: CustomChatTextField(friendUid: friendUid),
                  secondChild: const StreamVoiceWidget(),
                  crossFadeState:
                      BlocProvider.of<ChatCubit>(context).isRecording
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 260),
                ),
              ),
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
