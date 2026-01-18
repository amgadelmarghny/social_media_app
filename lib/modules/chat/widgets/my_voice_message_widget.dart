import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:social_media_app/shared/bloc/chat_cubit/chat_cubit.dart';
import 'package:social_media_app/shared/style/theme/constant.dart';
import 'package:voice_message_package/voice_message_package.dart';

class MyVoiceMessageWidget extends StatefulWidget {
  final String audioUrl;
  final DateTime dateTime;

  const MyVoiceMessageWidget({
    super.key,
    required this.audioUrl,
    required this.dateTime,
  });

  @override
  State<MyVoiceMessageWidget> createState() => _MyVoiceMessageWidgetState();
}

class _MyVoiceMessageWidgetState extends State<MyVoiceMessageWidget> {
  late VoiceController voiceController;

  @override
  void initState() {
    super.initState();
    // تعريف الكنترولر في initState
    voiceController = VoiceController(
      audioSrc: widget.audioUrl,
      maxDuration: const Duration(minutes: 10),
      isFile: false,
      onComplete: () {},
      onPlaying: () {
        // إبلاغ البلوك أن هذا الريكورد بدأ العمل ليتم إيقاف الآخرين
        context.read<ChatCubit>().notifyVoicePlaying(widget.audioUrl);
      },
      onPause: () {},
    );
  }

  @override
  void dispose() {
    // الكنترولر الخاص بهذه المكتبة يحتاج عمل dispose يدوي أحياناً لضمان توقف الصوت
    voiceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String date = DateFormat('hh:mm a').format(widget.dateTime);

    return BlocListener<ChatCubit, ChatState>(
      listener: (context, state) {
        // اللوجيك الخاص بك: إذا بدأ ريكورد آخر (URL مختلف) توقف عن العمل
        if (state is VoicePlayingStarted && state.audioUrl != widget.audioUrl) {
          if (voiceController.isPlaying) {
            voiceController.pausePlaying();
          }
        }
      },
      child: Align(
        alignment: Alignment.topRight,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.85,
          ),

          // Margin around the bubble
          margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 15),
          // Bubble decoration: color and rounded corners
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
                
                controller: voiceController,
                innerPadding: 10,
                cornerRadius: 20,
                backgroundColor: defaultColor,
                activeSliderColor: Colors.white,
                circlesColor: defaultTextColor,
                counterTextStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 20, bottom: 10),
                child: Text(
                  date,
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
