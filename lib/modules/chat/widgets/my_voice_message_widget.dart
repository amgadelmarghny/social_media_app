import 'dart:async';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:social_media_app/shared/bloc/chat_cubit/chat_cubit.dart';
import 'package:social_media_app/shared/style/theme/constant.dart';

/// Widget for rendering a voice message bubble sent by the current user.
class MyVoiceMessageWidget extends StatefulWidget {
  /// URL of the recorded audio file.
  final String audioUrl;

  /// Timestamp of when the message was sent.
  final DateTime dateTime;
  const MyVoiceMessageWidget(
      {super.key, required this.audioUrl, required this.dateTime});

  @override
  State<MyVoiceMessageWidget> createState() => _MyVoiceMessageWidgetState();
}

class _MyVoiceMessageWidgetState extends State<MyVoiceMessageWidget> {
  late PlayerController playerController;
  Duration totalDuration = Duration.zero;
  // Subscription for managing player state and updating the icon.
  StreamSubscription? _playerStateSubscription;

  @override
  void initState() {
    super.initState();
    playerController = PlayerController();
    _preparePlayer();

    // Listen to player state to update the icon automatically, avoids excessive manual setState
    _playerStateSubscription = playerController.onPlayerStateChanged.listen((_) {
      if (mounted) setState(() {});
    });
  }

  void _preparePlayer() async {
    try {
      await playerController.preparePlayer(
        path: widget.audioUrl,
        shouldExtractWaveform: true,
      );
      if (!mounted) return;
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
    // Stop player and dispose to avoid Codec error
    playerController.stopPlayer().then((_) => playerController.dispose());
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    String seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    String date = DateFormat('hh:mm a').format(widget.dateTime);

    return BlocListener<ChatCubit, ChatState>(
      // Listen for other voice messages being played so we can pause this one
      listener: (context, state) {
        if (state is VoicePlayingStarted && state.audioUrl != widget.audioUrl) {
          if (playerController.playerState.isPlaying) {
            playerController.pausePlayer();
          }
        }
      },
      child: Align(
        alignment: Alignment.topRight,
        child: Container(
          width: MediaQuery.sizeOf(context).width * 0.7, // Slightly wider for the time text
          padding: const EdgeInsets.only(top: 8, left: 10, right: 12, bottom: 5),
          margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 15),
          decoration: const BoxDecoration(
            color: defaultColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      playerController.playerState.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      if (playerController.playerState.isPlaying) {
                        await playerController.pausePlayer();
                      } else {
                        // Notify the cubit that this voice file is now playing
                        context.read<ChatCubit>().notifyVoicePlaying(widget.audioUrl);
                        await playerController.startPlayer();
                      }
                    },
                  ),
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
                  StreamBuilder<int>(
                    stream: playerController.onCurrentDurationChanged,
                    builder: (context, snapshot) {
                      // Show current playing duration, or total duration if not playing
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
              Text(
                date,
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}