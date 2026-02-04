import 'package:flutter/material.dart';
import 'package:social_media_app/models/notification_model.dart';
import 'package:social_media_app/shared/components/profile_picture_with_story.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';
import 'package:intl/intl.dart';
import 'package:social_media_app/shared/style/theme/constant.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel model;
  final VoidCallback onTap;

  const NotificationItem({
    super.key,
    required this.model,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: model.isRead
          ? Colors.transparent
          : Colors.grey.withValues(alpha: 0.2),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Row(
            children: [
              if (model.senderPhoto != null) ...[
                ProfilePictureWithStory(
                  image: model.senderPhoto,
                  isWithoutStory: true,
                  size: 45,
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                              text: '${model.senderName} ',
                              style: FontsStyle.font18PopinMedium()),
                          TextSpan(
                            text: _getNotificationText(),
                            style: FontsStyle.font14RegularForNotification(
                              color: const Color(0xffB1ACC7),
                            ),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      DateFormat.yMMMd().add_jm().format(model.dateTime),
                      style: FontsStyle.font12Popin(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              if (model.type == 'like' || model.type == 'comment')
                // Optionally show a small icon indicating type
                Icon(
                  model.type == 'like'
                      ? Icons.favorite
                      : Icons.comment_outlined,
                  size: 30,
                  color: model.type == 'like'
                      ? defaultColorButton
                      : Colors.white54,
                ),
              if (model.type == 'message' && model.subType == 'image')
                const Icon(Icons.image, size: 20, color: Colors.white54),
              if (model.type == 'message' && model.subType == 'voice')
                const Icon(Icons.mic, size: 20, color: Colors.white54),
              if (model.type == 'follow')
                const Icon(Icons.person_add, size: 30, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }

  String _getNotificationText() {
    if (model.type == 'like') {
      return 'liked your post';
    } else if (model.type == 'comment') {
      return model.content; // Content handles "commented: text"
    } else if (model.type == 'message') {
      return 'new message: ${model.content}'; // Content handles "Voice recording", "Sent an image", or text
    }
    return model.content;
  }
}
