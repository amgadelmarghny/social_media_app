import 'dart:async';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:social_media_app/shared/bloc/chat_cubit/chat_cubit.dart';
import 'package:social_media_app/shared/style/theme/constant.dart';

/// Widget to display a friend's voice message in a chat bubble.
class FriendVoiceMessageWidget extends StatefulWidget {
  final String audioUrl;   // URL for the friend's audio message
  final DateTime dateTime; // When the message was sent

  const FriendVoiceMessageWidget({
    super.key,
    required this.audioUrl,
    required this.dateTime,
  });

  @override
  State<FriendVoiceMessageWidget> createState() => _FriendVoiceMessageWidgetState();
}

class _FriendVoiceMessageWidgetState extends State<FriendVoiceMessageWidget> {
  late PlayerController playerController; // Controls audio playback
  Duration totalDuration = Duration.zero; // Total length of the audio
  StreamSubscription? _playerStateSubscription; // To update UI on play/pause changes

  @override
  void initState() {
    super.initState();
    playerController = PlayerController();
    _preparePlayer();

    // Listen to player state changes to update the play/pause icon automatically
    _playerStateSubscription = playerController.onPlayerStateChanged.listen((_) {
      if (mounted) setState(() {});
    });
  }

  /// Prepares the player by loading the audio and extracting the waveform.
  void _preparePlayer() async {
    try {
      await playerController.preparePlayer(
        path: widget.audioUrl,
        shouldExtractWaveform: true,
      );
      if (!mounted) return;
      // Get total duration once ready
      final duration = await playerController.getDuration(DurationType.max);
      setState(() {
        totalDuration = Duration(milliseconds: duration);
      });
    } catch (e) {
      debugPrint("Error preparing player: $e");
    }
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    // Stop player then dispose, prevents "Codec Released" error
    playerController.stopPlayer().then((_) => playerController.dispose());
    super.dispose();
  }

  /// Converts a [Duration] to mm:ss string.
  String _formatDuration(Duration duration) {
    String minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    String seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    // Format the sent time nicely
    String date = DateFormat('hh:mm a').format(widget.dateTime);

    return BlocListener<ChatCubit, ChatState>(
      // Listen for voice play control: pause this message if another file starts playing
      listener: (context, state) {
        if (state is VoicePlayingStarted && state.audioUrl != widget.audioUrl) {
          if (playerController.playerState.isPlaying) {
            playerController.pausePlayer();
          }
        }
      },
      child: Align(
        alignment: Alignment.topLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.7,
          ),
          margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 15),
          padding: const EdgeInsets.only(top: 8, left: 12, right: 15, bottom: 5),
          decoration: BoxDecoration(
            color: defaultColor.withValues(alpha: 0.6),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Play/Pause button
                  IconButton(
                    icon: Icon(
                      playerController.playerState.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      if (playerController.playerState.isPlaying) {
                        await playerController.pausePlayer();
                      } else {
                        // Notify cubit a new voice message has started playing
                        context.read<ChatCubit>().notifyVoicePlaying(widget.audioUrl);
                        await playerController.startPlayer();
                      }
                    },
                  ),
                  // Waveform display (seekable)
                  Expanded(
                    child: AudioFileWaveforms(
                      size: const Size(double.infinity, 35),
                      playerController: playerController,
                      enableSeekGesture: true,
                      waveformType: WaveformType.fitWidth,
                      playerWaveStyle: const PlayerWaveStyle(
                        fixedWaveColor: Colors.white38,
                        liveWaveColor: Colors.white,
                        spacing: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Show elapsed or total duration
                  StreamBuilder<int>(
                    stream: playerController.onCurrentDurationChanged,
                    builder: (context, snapshot) {
                      Duration currentPos = playerController.playerState.isPlaying
                          ? Duration(milliseconds: snapshot.data ?? 0)
                          : totalDuration;
                      return Text(
                        _formatDuration(currentPos),
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                      );
                    },
                  ),
                ],
              ),
              // Sent time in smaller font
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  date,
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}