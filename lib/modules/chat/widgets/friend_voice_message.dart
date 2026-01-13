import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:social_media_app/shared/style/theme/constant.dart';

/// Widget to display a friend's voice message in a chat bubble.
class FriendVoiceMessageWidget extends StatefulWidget {
  /// URL of the audio file to play.
  final String audioUrl;

  /// Date and time when the message was sent.
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
  // Controller that manages playback of the audio file
  late PlayerController playerController;

  // Stores the total duration of the audio file for display
  Duration totalDuration =
      Duration.zero; // To store the total duration of the record

  @override
  void initState() {
    super.initState();
    // Initialize the player controller
    playerController = PlayerController();
    // Load the audio file and prepare the visual waveform and duration
    _preparePlayer();
  }

  /// Loads the audio file using the PlayerController, extracts waveform, and gets duration.
  void _preparePlayer() async {
    await playerController.preparePlayer(
      path: widget.audioUrl,
      shouldExtractWaveform:
          true, // Extract waveform visualization from the audio file
    );
    if (!mounted) return;
    // Get audio file's total duration as milliseconds and convert to Duration
    final duration = await playerController.getDuration(DurationType.max);
    setState(() {
      totalDuration = Duration(milliseconds: duration);
    });
  }

  @override
  void dispose() {
    try {
      // Properly dispose the resources used by the controller
      playerController.dispose();
    } catch (e) {
      print('Error disposing controller: $e');
    }
    super.dispose();
  }

  /// Formats a Duration as mm:ss (for progress/time display)
  String _formatDuration(Duration duration) {
    String minutes =
        duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    String seconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    // Format the sent time as e.g. "02:15 PM"
    String date = DateFormat('hh:mm a').format(widget.dateTime);

    return Align(
      alignment: Alignment
          .topLeft, // Put the bubble on the left (for friend's messages)
      child: Container(
        // Limit bubble width to 70% of total screen width for nice look
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.7,
        ),
        // Add some space around the bubble
        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 15),
        // Add space inside the bubble for padding
        padding: const EdgeInsets.only(top: 8, left: 12, right: 15),
        // Decorate the bubble with color and rounded corners
        decoration: BoxDecoration(
          color:
              defaultColor.withValues(alpha: 0.6), // Make it semi-transparent
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align to left inside bubble
          children: [
            Row(
              children: [
                // Play or pause button for the audio message
                IconButton(
                  icon: Icon(
                    playerController.playerState.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                  ),
                  onPressed: () async {
                    // Switch between playing and pausing based on current state
                    if (playerController.playerState.isPlaying) {
                      await playerController.pausePlayer();
                    } else {
                      await playerController.startPlayer();
                    }
                    // Need to call setState to update button/icon
                    setState(() {});
                  },
                ),
                // Display the waveform and allow seeking by touching it
                Expanded(
                  child: AudioFileWaveforms(
                    size: Size(MediaQuery.sizeOf(context).width * 0.7, 35),
                    playerController: playerController,
                    enableSeekGesture:
                        true, // Allow the user to seek by tapping on the waveform
                    waveformType: WaveformType.fitWidth,
                    playerWaveStyle: const PlayerWaveStyle(
                      fixedWaveColor:
                          Colors.grey, // The color of the unplayed waveform
                      liveWaveColor: Colors
                          .white, // Color of the waveform under the head (current playback)
                      spacing: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Show current progress if playing, otherwise show the total duration
                StreamBuilder<int>(
                  stream: playerController.onCurrentDurationChanged,
                  builder: (context, snapshot) {
                    // If playing, display the current position; if stopped, display totalDuration
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
            // Date/time label under the controls, in faded white
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
