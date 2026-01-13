import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/shared/bloc/chat_cubit/chat_cubit.dart';
import 'package:social_media_app/shared/style/theme/constant.dart';

/// A widget that builds an animated amplitude bar and recording timer based on the audio input stream.
class StreamVoiceWidget extends StatelessWidget {
  const StreamVoiceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: EdgeInsets.symmetric(horizontal: 20),
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(30)),
        // color: Color(0XFF938DA2),
      ),
      // height: 50,
      child: AudioWaveforms(
        backgroundColor: const Color(0XFF938DA2),
        recorderController:
            BlocProvider.of<ChatCubit>(context).recorderController,
        size: const Size(300, 50),
        waveStyle: const WaveStyle(
          waveColor: defaultColor,
          showMiddleLine: true,
          spacing: 6,
          middleLineColor: Color(0XFFC4C2CB),
        ),
      ),
    );
  }

  /// Helper function to format duration (in seconds) into mm:ss string
  // String _formatDuration(int seconds) {
  //   final min = (seconds ~/ 60).toString().padLeft(2, '0');
  //   final sec = (seconds % 60).toString().padLeft(2, '0');
  //   return "$min:$sec";
  // }
}
