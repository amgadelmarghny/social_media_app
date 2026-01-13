import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:social_media_app/models/message_model.dart';
import 'package:social_media_app/shared/bloc/chat_cubit/chat_cubit.dart';
import 'package:social_media_app/shared/components/constants.dart';
import 'package:social_media_app/shared/network/local/cache_helper.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';

class CustomChatTextField extends StatelessWidget {
  const CustomChatTextField({
    super.key,
    required this.friendUid,
  });

  final String friendUid;

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();

    return TextFormField(
      controller: controller,
      onFieldSubmitted: (value) async {
        MessageModel model = MessageModel(
            message: controller.text,
            uid: CacheHelper.getData(key: kUidToken),
            friendUid: friendUid,
            dateTime: DateTime.now());
        await BlocProvider.of<ChatCubit>(context).sendMessages(model)
            //  .then((value) {
            // if (context.mounted) {
            //   BlocProvider.of<ChatCubit>(context)
            //       .pushMessageNotificationToTheFriend(
            //     token: friendToken,
            //     title: "New message from ${model.uid}",
            //     content: controller.text,
            //   );
            // }
            //})
            ;
        controller.clear();
      },
      style: FontsStyle.font18PopinWithShadowOption(),
      decoration: InputDecoration(
        suffixIcon: IconButton(
          onPressed: () {
            MessageModel model = MessageModel(
                message: controller.text,
                uid: CacheHelper.getData(key: kUidToken),
                friendUid: friendUid,
                dateTime: DateTime.now());
            BlocProvider.of<ChatCubit>(context).sendMessages(model);
            controller.clear();
          },
          icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedSent,
            size: 28,
            color: Color(0XFFC4C2CB),
          ),
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
