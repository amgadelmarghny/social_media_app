import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';
import 'package:social_media_app/shared/style/theme/constant.dart';

/// A chat bubble widget for displaying messages from a friend.
/// Aligns the bubble to the left and uses the app's default color.
class FriendBubbleMessage extends StatelessWidget {
  /// The message text to display.
  final String message;

  /// The date and time the message was sent.
  final DateTime dateTime;

  const FriendBubbleMessage({
    super.key,
    required this.message,
    required this.dateTime,
  });

  @override
  Widget build(BuildContext context) {

    // Format the date to a readable string, e.g., "02:15 PM"
    String date = DateFormat('hh:mm a').format(dateTime);

    return Align(
      alignment: Alignment.topLeft, // Align bubble to the left
      child: Container(
        // Limit the bubble's width to 85% of the screen
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.85,
        ),
        // Margin around the bubble
        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 15),
        // Padding inside the bubble
        padding: const EdgeInsets.only(top: 8, left: 12, right: 15),
        // Bubble decoration: color and rounded corners
        decoration: const BoxDecoration(
          color: defaultColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
          children: [
            // The message text
            Text(
              message,
              overflow: TextOverflow.visible,
              style: FontsStyle.font18PopinMedium(),
            ),
            // The formatted time below the message
            Text(
              date,
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}
