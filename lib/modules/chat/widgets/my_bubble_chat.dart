import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:social_media_app/shared/components/custom_read_more_text.dart';
import 'package:social_media_app/shared/style/theme/constant.dart';

/// A chat bubble widget for displaying the current user's messages.
/// Aligns the bubble to the right and uses the app's default color.
class MyBubbleChat extends StatelessWidget {
  /// The message text to display.
  final String message;

  /// The date and time the message was sent.
  final DateTime dateTime;

  const MyBubbleChat({
    super.key,
    required this.message,
    required this.dateTime,
    required this.isRead,
    required this.isDelivered,
    required this.isSending,
  });

  final bool isRead;
  final bool isDelivered, isSending;

  @override
  Widget build(BuildContext context) {
    // Format the date to a readable string, e.g., "02:15 PM"
    String date = DateFormat('hh:mm a').format(dateTime);

    return Align(
      alignment: Alignment.topRight, // Align bubble to the right
      child: Container(
        // Limit the bubble's width to 85% of the screen
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.85,
        ),
        // Padding inside the bubble
        padding: const EdgeInsets.only(top: 8, left: 15, right: 12),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end, // Align text to the right
          children: [
            // The message text
            CustomReadMoreText(text: message),
            // The formatted time below the message
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  date,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(width: 5),
                Icon(
                  isSending
                      ? Icons.timer_outlined
                      : isRead
                          ? Icons.done_all
                          : isDelivered
                              ? Icons.done_all
                              : Icons.check,
                  size: 16,
                  color: isRead || !isSending
                      ? const Color(0xff3B21B2)
                      : const Color(0XFFC4C2CB),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
