import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:intl/intl.dart';
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
  });

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
                child: GridView.builder(
                  shrinkWrap: true, // Enables GridView inside Column.
                  physics:
                      const NeverScrollableScrollPhysics(), // Disable inner scroll.
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    // Use 2 columns for 2+ images, or just 1.
                    crossAxisCount: images.length >= 2 ? 2 : 1,
                    crossAxisSpacing:
                        5, // Space horizontally between grid tiles.
                    mainAxisSpacing: 5, // Space vertically between grid tiles.
                  ),
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(
                          15), // Round corners for images.
                      child: CachedNetworkImage(
                        imageUrl: images[index], // The image URL for display.
                        fit: BoxFit.cover, // Clip and zoom to fill box.
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        errorWidget: (context, url, error) => const HugeIcon(
                          icon: HugeIconsStrokeRounded
                              .alert02, // Error icon if image fails.
                        ),
                      ),
                    );
                  },
                ),
              ),
            // Show text message if not null.
            if (message != null)
              // Displays (possibly long) text with read-more/less feature.
              CustomReadMoreText(text: message!),
            // Timestamp below the content, right-aligned, muted color.
            Text(
              date,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
