import 'package:flutter/material.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';
import 'package:social_media_app/shared/style/theme/constant.dart';

class FriendBubbleMessage extends StatelessWidget {
  const FriendBubbleMessage({
    super.key,
    required this.message,
    required this.dateTime,
  });
  final String message;
  final DateTime dateTime;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.85,
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 15),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: const BoxDecoration(
          color: defaultColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
        ),
        child: Text(
          message,
          overflow: TextOverflow.visible,
          style: FontsStyle.font18PopinMedium(),
        ),
      ),
    );
  }
}
