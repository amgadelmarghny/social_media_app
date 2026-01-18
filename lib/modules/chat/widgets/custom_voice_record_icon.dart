import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:social_media_app/shared/bloc/chat_cubit/chat_cubit.dart';
import 'package:social_media_app/shared/components/show_toast.dart';

/// A button widget that triggers voice recording or sending a recorded voice message.
/// Changes icon and appearance based on recording state and upload process.
class CustomVoiceRecordIcon extends StatelessWidget {
  const CustomVoiceRecordIcon({super.key, required this.friendUid});
  final String friendUid;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatCubit, ChatState>(
      listener: (context, state) {
        // Listen for errors and display a toast notification if any recording/upload fails.
        if (state is UploadRecordFailure) {
          showToast(msg: state.errMessage, toastState: ToastState.error);
        } else if (state is RecordAndUploadAVoiceFailureState) {
          showToast(msg: state.errMessage, toastState: ToastState.error);
        }
      },
      builder: (context, state) {
        var cubit = context.read<ChatCubit>();

        // Show a loading indicator if a voice file is being uploaded.
        if (state is UploadRecordLoading) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0XFFC4C2CB),
              ),
            ),
          );
        }

        // Default: show microphone (to start recording) or send icon (to send voice) depending on whether recording or not.
        return IconButton(
          onPressed: () async {
            await cubit.recordAVoiceThenSendIt(friendUid: friendUid);
          },
          icon: AnimatedCrossFade(
            // Shown before user starts recording: mic icon
            firstChild: const HugeIcon(
              icon: HugeIcons.strokeRoundedMic01,
              color: Color(0XFFC4C2CB),
            ),
            // Shown while user is recording: send icon (use a highlight color)
            secondChild: const HugeIcon(
              icon: HugeIcons
                  .strokeRoundedSent, // Send icon displayed during recording
              color: Colors.blue, // Use a blue color to draw user attention
            ),
            crossFadeState: cubit.isRecording
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 260),
          ),
        );
      },
    );
  }
}
