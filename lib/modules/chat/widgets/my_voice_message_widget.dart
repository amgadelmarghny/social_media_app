import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  late PlayerController
      playerController; // Controller for handling audio playback.
  Duration totalDuration =
      Duration.zero; // Stores the total duration of the audio.

  @override
  void initState() {
    super.initState();
    playerController = PlayerController(); // Initialize the player controller.
    _preparePlayer(); // Prepare (load) the audio player.
  }

  /// Prepares the audio player and fetches the waveform and file duration.
  void _preparePlayer() async {
    if (mounted) {
      // Load the audio file from the provided URL.
      await playerController.preparePlayer(
        path: widget.audioUrl,
        shouldExtractWaveform:
            true, // Extracts waveform data for visualization.
      );
      if (!mounted) return;
      // Get the total duration of the audio so we can display it when playback is stopped.
      final duration = await playerController.getDuration(DurationType.max);
      setState(() {
        totalDuration = Duration(milliseconds: duration);
      });
    }
  }

  @override
  void dispose() {
    try {
      playerController.dispose(); // Clean up the audio player controller.
    } catch (e) {
      print('Error disposing controller: $e');
    }
    super.dispose();
  }

  /// Formats duration as "mm:ss" for display.
  String _formatDuration(Duration duration) {
    String minutes =
        duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    String seconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    // Format the message timestamp (e.g., "09:41 PM").
    String date = DateFormat('hh:mm a').format(widget.dateTime);

    return Align(
      alignment: Alignment.topRight, // Bubble appears on the right side.
      child: Container(
        // Limit the width of the bubble to 60% of the screen.
        width: MediaQuery.sizeOf(context).width * 0.6,
        // Internal padding for bubble content.
        padding: const EdgeInsets.only(top: 8, left: 15, right: 12),
        // Margin spacing outside bubble.
        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 15),
        // Styling for the bubble: colored and rounded corners.
        decoration: const BoxDecoration(
          color: defaultColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end, // Contents right-aligned.
          children: [
            Row(
              children: [
                // Button to play or pause audio.
                IconButton(
                  icon: Icon(playerController.playerState.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow),
                  onPressed: () async {
                    // Toggle play/pause on tap.
                    if (playerController.playerState.isPlaying) {
                      await playerController.pausePlayer();
                    } else {
                      await playerController.startPlayer();
                    }
                    setState(() {}); // Refresh UI to update icon state.
                  },
                ),
                // Waveform visualization and seeking control.
                Expanded(
                  child: AudioFileWaveforms(
                    size: Size(MediaQuery.sizeOf(context).width * 0.7, 35),
                    playerController: playerController,
                    enableSeekGesture: true, // Allow seeking in the waveform.
                    waveformType: WaveformType.fitWidth,
                    playerWaveStyle: const PlayerWaveStyle(
                      fixedWaveColor: Colors.grey,
                      liveWaveColor: Colors.white,
                      spacing: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Duration display: either remaining or current audio time.
                StreamBuilder<int>(
                  stream: playerController.onCurrentDurationChanged,
                  builder: (context, snapshot) {
                    // If audio is playing, show current time; if stopped, show total.
                    Duration currentPos = playerController.playerState.isPlaying
                        ? Duration(milliseconds: snapshot.data ?? 0)
                        : totalDuration;

                    return Text(
                      _formatDuration(currentPos),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    );
                  },
                ),
              ],
            ),
            // Message timestamp below the main row.
            Text(
              date,
              style: const TextStyle(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}
