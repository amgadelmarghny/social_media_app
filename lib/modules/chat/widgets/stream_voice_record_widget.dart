import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:record/record.dart';
import 'package:social_media_app/shared/bloc/chat_cubit/chat_cubit.dart';
import 'package:social_media_app/shared/style/theme/constant.dart';

/// A widget that builds an animated amplitude bar and recording timer based on the audio input stream.
/// This widget visually reacts to real-time audio input for the voice recorder.
class StreamVoiceWidget extends StatelessWidget {
  const StreamVoiceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtain the ChatCubit, which manages the amplitude stream.
    final cubit = context.read<ChatCubit>();

    return LayoutBuilder(
      // LayoutBuilder gives access to the constraints for responsive design.
      builder: (context, constraints) {
        return Container(
          height: 50, // Fixed height for the amplitude bar container.
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(30)),
            // Adds a semi-transparent background color for improved appearance.
            color: const Color(0XFF938DA2).withValues(alpha: 0.2),
          ),
          // Listen to amplitude changes and rebuild the bar animation.
          child: StreamBuilder<Amplitude>(
            stream: cubit.amplitudeStream,
            builder: (context, asyncSnapshot) {
              // Get the current amplitude value or a default if not available.
              final amp = asyncSnapshot.data?.current ?? -160.0;
              // Normalize and clamp the amplitude to a 0.0 - 1.0 scale.
              final factor = ((amp + 160) / 160).clamp(0.0, 1.0);

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                // Draw 20 animated bars; height is calculated from the amplitude.
                children: List.generate(20, (index) {
                  // Calculate height. Adds variation by using (index % 3 + 1).
                  double animatedHeight =
                      5 + (30 * factor * ((index % 3 + 1) / 3));
                  // Each bar animates its height smoothly as amplitude changes.
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: 3,
                    height: animatedHeight,
                    decoration: BoxDecoration(
                      color: defaultColor,
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                  );
                }),
              );
            },
          ),
        );
      },
    );
  }
}
