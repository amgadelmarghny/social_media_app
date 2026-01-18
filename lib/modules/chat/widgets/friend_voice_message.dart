import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:social_media_app/shared/bloc/chat_cubit/chat_cubit.dart';
import 'package:social_media_app/shared/style/theme/constant.dart';
import 'package:voice_message_package/voice_message_package.dart';

/// A widget to display a voice message from a friend in chat.
/// Displays a bubble on the left with color/shape matching friend chat.
class FriendVoiceMessageWidget extends StatefulWidget {
  /// Required audio file URL for the voice message
  final String audioUrl;
  /// Date/time when the voice message was sent
  final DateTime dateTime;

  const FriendVoiceMessageWidget({
    super.key,
    required this.audioUrl,
    required this.dateTime,
  });

  @override
  State<FriendVoiceMessageWidget> createState() =>
      _FriendVoiceMessageWidgetState();
}

class _FriendVoiceMessageWidgetState extends State<FriendVoiceMessageWidget> {
  late VoiceController voiceController;

  @override
  void initState() {
    super.initState();
    // Initialize the voice controller, configuring it with the given audio URL.
    // onPlaying notifies the Cubit so other playing voices (self or friend)
    // can be paused elsewhere when a new message starts.
    voiceController = VoiceController(
      audioSrc: widget.audioUrl,
      maxDuration: const Duration(minutes: 10),
      isFile: false,
      onComplete: () {},
      onPlaying: () {
        // Notify the Cubit that this friend's voice message started playing.
        // This allows the Cubit to pause other voice messages that are playing,
        // ensuring only one audio plays at a time.
        context.read<ChatCubit>().notifyVoicePlaying(widget.audioUrl);
      },
      onPause: () {},
    );
  }

  @override
  void dispose() {
    // Dispose the voice controller when the widget is removed from memory
    voiceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Format the send time, e.g., "02:15 PM"
    String date = DateFormat('hh:mm a').format(widget.dateTime);

    return BlocListener<ChatCubit, ChatState>(
      listener: (context, state) {
        // If another voice message (mine or friend's) starts playing
        // with a different URL, pause this controller if it's playing.
        if (state is VoicePlayingStarted && state.audioUrl != widget.audioUrl) {
          if (voiceController.isPlaying) {
            voiceController.pausePlaying();
          }
        }
      },
      child: Align(
        alignment: Alignment.topLeft, // Bubble aligns to the left for friend
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.85,
          ),
          // Margin around the bubble
          margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 15),
          // Bubble decoration: color and rounded corners for friend
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 101, 87, 148),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Stack(
            alignment: AlignmentGeometry.bottomRight,
            children: [
              // Main voice message player widget
              VoiceMessageView(
                controller: voiceController,
                innerPadding: 10,
                cornerRadius: 20,
                backgroundColor: const Color.fromARGB(255, 101, 87, 148),
                activeSliderColor: Colors.white,
                circlesColor: defaultTextColor,
                counterTextStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              // Time label at the bottom right of the bubble
              Padding(
                padding: const EdgeInsets.only(right: 20, bottom: 10),
                child: Text(
                  date,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
