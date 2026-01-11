import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:record/record.dart';
import 'package:social_media_app/shared/bloc/chat_cubit/chat_cubit.dart';
import 'package:social_media_app/shared/components/constants.dart';
import 'package:social_media_app/shared/components/show_toast.dart';
import 'package:social_media_app/shared/network/local/cache_helper.dart';

class VoiceRecordWidget extends StatelessWidget {
  const VoiceRecordWidget({
    super.key,
    required this.friendUid,
  });
  final String friendUid;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        await BlocProvider.of<ChatCubit>(context).recordAndUploadAVoice(
            myUid: CacheHelper.getData(key: kUidToken), friendUid: friendUid);
      },
      icon: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          if (state is UploadRecordFailure) {
            showToast(msg: state.errMessage, toastState: ToastState.error);
          } else if (state is RecordAndUploadAVoiceFailureState) {
            showToast(msg: state.errMessage, toastState: ToastState.error);
          }
        },
        builder: (context, state) {
          return AnimatedCrossFade(
              firstChild: const HugeIcon(
                icon: HugeIcons.strokeRoundedMic01,
                color: Color(0XFFC4C2CB),
              ),
              secondChild: const HugeIcon(
                icon: HugeIcons.strokeRoundedSent,
                color: Color(0XFFC4C2CB),
              ),
              crossFadeState: BlocProvider.of<ChatCubit>(context).isRecording
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300));
        },
      ),
    );
  }
}
