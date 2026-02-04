import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:social_media_app/models/message_model.dart';
import 'package:social_media_app/shared/bloc/chat_cubit/chat_cubit.dart';
import 'package:social_media_app/shared/components/constants.dart';
import 'package:social_media_app/shared/network/local/cache_helper.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';

class CustomChatTextField extends StatefulWidget {
  const CustomChatTextField({
    super.key,
    required this.friendUid,
    required this.controller,
  });

  final String friendUid;
  final TextEditingController controller;

  @override
  State<CustomChatTextField> createState() => _CustomChatTextFieldState();
}

class _CustomChatTextFieldState extends State<CustomChatTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      minLines: 1,
      maxLines: 5,
      keyboardType: TextInputType.multiline,
      controller: widget.controller,
      onFieldSubmitted: (value) async {
        if (BlocProvider.of<ChatCubit>(context).pickedImages.isNotEmpty) {
          await BlocProvider.of<ChatCubit>(context)
              .uploadAndSendPickedImagesWithTextMessageOrNot(
            friendUid: widget.friendUid,
            textMessage: widget.controller.text.isNotEmpty
                ? widget.controller.text
                : null,
          );
        } else {
          if (widget.controller.text.isNotEmpty) {
            widget.controller.clear();

            MessageModel model = MessageModel(
                textMessage: widget.controller.text,
                uid: CacheHelper.getData(key: kUidToken),
                friendUid: widget.friendUid,
                dateTime: DateTime.now());
            await BlocProvider.of<ChatCubit>(context).sendAMessage(model);
          }
        }
      },
      style: FontsStyle.font18PopinWithShadowOption(),
      decoration: InputDecoration(
        suffixIcon: BlocBuilder<ChatCubit, ChatState>(
          builder: (context, state) {
            return AbsorbPointer(
              absorbing:
                  state is SendMessageLoading || state is UploadImageLoading,
              child: IconButton(
                onPressed: () async {
                  if (BlocProvider.of<ChatCubit>(context)
                      .pickedImages
                      .isNotEmpty) {
                    await BlocProvider.of<ChatCubit>(context)
                        .uploadAndSendPickedImagesWithTextMessageOrNot(
                      friendUid: widget.friendUid,
                      textMessage: widget.controller.text.isNotEmpty
                          ? widget.controller.text
                          : null,
                    );
                  } else {
                    if (widget.controller.text.isNotEmpty) {
                      MessageModel model = MessageModel(
                          textMessage: widget.controller.text,
                          uid: CacheHelper.getData(key: kUidToken),
                          friendUid: widget.friendUid,
                          dateTime: DateTime.now());
                      widget.controller.clear();
                      await BlocProvider.of<ChatCubit>(context)
                          .sendAMessage(model);
                    }
                  }
                },
                icon:
                    (state is SendMessageLoading || state is UploadImageLoading)
                        ? const SizedBox(
                            height: 25,
                            width: 25,
                            child: CircularProgressIndicator(
                              color: Color(0XFFC4C2CB),
                              strokeWidth: 2,
                            ),
                          )
                        : const HugeIcon(
                            icon: HugeIcons.strokeRoundedSent,
                            size: 28,
                            color: Color(0XFFC4C2CB),
                          ),
              ),
            );
          },
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        filled: true,
        fillColor: const Color(0XFF938DA2),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0XFF938DA2)),
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0XFF938DA2)),
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
      ),
    );
  }
}
