import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:social_media_app/models/message_model.dart';
import 'package:social_media_app/shared/bloc/chat_cubit/chat_cubit.dart';
import 'package:social_media_app/shared/components/constants.dart';
import 'package:social_media_app/shared/network/local/cache_helper.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';
import 'package:social_media_app/shared/style/theme/constant.dart';

class ChatViewInteracrive extends StatelessWidget {
  const ChatViewInteracrive({
    super.key,
    required this.friendUid,
  });
  final String friendUid;
  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();
    return Container(
      color: defaultColor,
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
        top: 10,
        bottom: MediaQuery.viewPaddingOf(context).bottom,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              HugeIcons.strokeRoundedImageAdd02,
              color: Color(0XFFC4C2CB),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              onFieldSubmitted: (value) {
                MessageModel model = MessageModel(
                    message: controller.text,
                    uid: CacheHelper.getData(key: kUidToken),
                    friendUid: friendUid,
                    dateTime: DateTime.now());
                BlocProvider.of<ChatCubit>(context).sendMessages(model);
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
                  icon: const Icon(
                    HugeIcons.strokeRoundedSent,
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
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              HugeIcons.strokeRoundedMic01,
              color: Color(0XFFC4C2CB),
            ),
          ),
        ],
      ),
    );
  }
}
