import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:social_media_app/modules/chat/widgets/custom_gradle_images_message.dart';
import 'package:social_media_app/shared/components/custom_read_more_text.dart';
import 'package:social_media_app/shared/style/theme/constant.dart';

/// A chat bubble widget for displaying the current user's photos (optionally with text).
/// Aligns the bubble to the right and uses the app's default color.
class MyPhotosWithTextMessageBubbleChat extends StatelessWidget {
  /// The message text to display (nullable because it may be just a photo message).
  final String? message;

  /// The list of image URLs to display in the chat bubble.
  final List<String> images;

  /// The date and time the message was sent.
  final DateTime dateTime;

  /// Creates a chat bubble for displaying images and optional text.
  const MyPhotosWithTextMessageBubbleChat({
    super.key,
    required this.message,
    required this.images,
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
      alignment: Alignment.topRight, // Align the chat bubble to the right.
      child: Container(
        clipBehavior: Clip.antiAlias,
        padding: const EdgeInsets.only(top: 5, left: 5, right: 5),
        // Margin around the bubble for separation from other chat content.
        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 15),
        // Bubble decoration: uses the app default color and rounded corners.
        decoration: const BoxDecoration(
          color: defaultColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
            bottomLeft: Radius.circular(15),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.end, // Align text & time to right.
          children: [
            // Show image grid if images exist.
            if (images.isNotEmpty)
              Container(
                // Cap the grid width to prevent overflow.
                constraints: const BoxConstraints(maxWidth: 250),
                child: CustomGradleImagesMessage(images: images),
              ),
            // Show text message if not null.
            if (message != null)
              // Displays (possibly long) text with read-more/less feature.
              CustomReadMoreText(text: message!),
            // Timestamp below the content, right-aligned, muted color.
            // Timestamp below the content, right-aligned, muted color.
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
