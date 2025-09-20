import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/social_cubit/social_cubit.dart';
import '../style/fonts/font_style.dart';

class FloatingErrorWidget extends StatelessWidget {
  const FloatingErrorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    SocialCubit socialCubit = BlocProvider.of<SocialCubit>(context);

    return Column(
      children: [
        const Icon(
          Icons.new_releases_outlined,
          size: 60,
          color: Colors.red,
        ),
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          width: MediaQuery.sizeOf(context).width / 1.5,
          height: 50,
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    socialCubit.cancelPostDuringCreating();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.close,
                        size: 30,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        'Cancel',
                        style: FontsStyle.font18PopinMedium(),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    final DateTime now = DateTime.now();
                    final currentTime = DateTime(
                        now.year, now.month, now.day, now.hour, now.minute);
                    if (socialCubit.postImagePicked != null) {
                      socialCubit.createPostWithPhoto(
                        postContent: socialCubit.postContentController.text,
                        dateTime: currentTime,
                      );
                      return;
                    } else if (socialCubit
                        .postContentController.text.isNotEmpty) {
                      socialCubit.createPostWithContentOnly(
                        postContent: socialCubit.postContentController.text,
                        dateTime: currentTime,
                      );
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.refresh_outlined,
                        color: Colors.blue,
                        size: 30,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        'Try again',
                        style: FontsStyle.font18PopinMedium()
                            .copyWith(color: Colors.blue, fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
