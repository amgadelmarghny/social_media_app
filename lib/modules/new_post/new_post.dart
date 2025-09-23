import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/modules/new_post/widgets/new_post_body.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import 'package:social_media_app/shared/style/theme/constant.dart';
import 'package:social_media_app/shared/style/theme/theme.dart';
import '../../shared/style/fonts/font_style.dart';

class CreatePostSheet extends StatelessWidget {
  const CreatePostSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    SocialCubit socialCubit = BlocProvider.of<SocialCubit>(context);
    return Container(
      decoration: themeColor(),
      padding: const EdgeInsets.only(top: 40),
      child: BlocBuilder<SocialCubit, SocialState>(
        builder: (BuildContext context, SocialState state) {
          return Scaffold(
            appBar: AppBar(
              actions: [
                // to notice the text filed input changes
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: socialCubit.postContentController,
                  builder: (context, value, child) {
                    return Container(
                      height: 40,
                      width: 90,
                      clipBehavior: Clip.hardEdge,
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      child: MaterialButton(
                        color: socialCubit.postImagePicked == null &&
                                value.text.isEmpty
                            ? Colors.white70
                            : defaultColorButton,
                        onPressed: () {
                          final DateTime now = DateTime.now();
                          // final currentTime = DateTime(now.year, now.month,
                          //     now.day, now.hour, now.minute);
                          if (socialCubit.postImagePicked != null) {
                            socialCubit.createPostWithPhoto(
                              postContent: value.text,
                              dateTime: now,
                            );
                            Navigator.pop(context);
                          } else if (value.text.isNotEmpty) {
                            socialCubit.createPostWithContentOnly(
                              postContent: value.text,
                              dateTime: now,
                            );
                            Navigator.pop(context);
                          }
                        },
                        child: Text(
                          'Post',
                          style: FontsStyle.font18PopinMedium().copyWith(
                            color: socialCubit.postImagePicked == null &&
                                    value.text.isEmpty
                                ? Colors.black54
                                : null,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(
                  width: 20,
                )
              ],
            ),
            body: const CreatePostSheetBody(),
          );
        },
      ),
    );
  }
}
