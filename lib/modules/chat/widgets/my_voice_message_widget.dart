import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:social_media_app/shared/bloc/chat_cubit/chat_cubit.dart';
import 'package:social_media_app/shared/style/theme/constant.dart';
import 'package:voice_message_package/voice_message_package.dart';

/// Widget to display a voice message sent by the user (My message bubble)
class MyVoiceMessageWidget extends StatefulWidget {
  final String audioUrl; // The URL of the audio file to play
  final DateTime dateTime; // The timestamp of the message

  const MyVoiceMessageWidget({
    super.key,
    required this.audioUrl,
    required this.dateTime,
    required this.isRead,
    required this.isDelivered,
    required this.isSending,
  });

  final bool isRead;
  final bool isDelivered, isSending;

  @override
  State<MyVoiceMessageWidget> createState() => _MyVoiceMessageWidgetState();
}

class _MyVoiceMessageWidgetState extends State<MyVoiceMessageWidget> {
  late VoiceController
      voiceController; // Controller for handling voice message playback

  @override
  void initState() {
    super.initState();
    // Initialize the VoiceController in initState
    voiceController = VoiceController(
      audioSrc: widget.audioUrl,
      maxDuration: const Duration(minutes: 10),
      isFile: false,
      onComplete: () {
        // Called when playback completes
      },
      onPlaying: () {
        // Notify the Bloc that this record started playing to pause others
        context.read<ChatCubit>().notifyVoicePlaying(widget.audioUrl);
      },
      onPause: () {
        // Called when playback is paused
      },
    );
  }

  @override
  void dispose() {
    // The controller needs manual disposal sometimes to ensure the audio is stopped
    voiceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Format the message timestamp to "hour:minute am/pm"
    String date = DateFormat('hh:mm a').format(widget.dateTime);

    return BlocListener<ChatCubit, ChatState>(
      listener: (context, state) {
        // Logic: If a different voice message started playing, pause this one
        if (state is VoicePlayingStarted && state.audioUrl != widget.audioUrl) {
          if (voiceController.isPlaying) {
            voiceController.pausePlaying();
          }
        }
      },
      child: Align(
        alignment:
            Alignment.topRight, // Align this bubble to the right (my messages)
        child: Container(
          constraints: BoxConstraints(
            maxWidth:
                MediaQuery.sizeOf(context).width * 0.85, // Limit bubble width
          ),
          // Margin around the bubble
          margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 15),
          // Bubble styling (color and rounded corners)
          decoration: const BoxDecoration(
            color: defaultColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
          ),
          child: Stack(
            alignment: AlignmentGeometry.bottomRight,
            children: [
              VoiceMessageView(
                // Widget for displaying and playing the voice message
                controller: voiceController,
                innerPadding: 10,
                cornerRadius: 20,
                backgroundColor: defaultColor,
                activeSliderColor: Colors.white, // Active slider bar color
                circlesColor: defaultTextColor, // Color for the sound circles
                counterTextStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 11, // Style for the timer/counter
                ),
              ),
              // Message time in bottom-right corner
              Padding(
                padding: const EdgeInsets.only(right: 12, bottom: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      date,
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      widget.isSending
                          ? Icons.timer_outlined
                          : widget.isRead
                              ? Icons.done_all
                              : widget.isDelivered
                                  ? Icons.done_all
                                  : Icons.check,
                      size: 16,
                      color: widget.isRead || !widget.isSending
                          ? const Color(0xff3B21B2)
                          : const Color(0XFFC4C2CB),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
