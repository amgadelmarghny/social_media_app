import 'package:flutter/material.dart';
import '../../../shared/components/profile_picture_with_story.dart';
import '../../../shared/style/fonts/font_style.dart';

class ProfilePostRow extends StatelessWidget {
  const ProfilePostRow({
    super.key,
    required this.image,
    required this.userName,
    this.timePosted,
  });
  final String? image;
  final String userName;
  final String? timePosted;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // timePosted != null that mean remove more_vert & timePosted
        // when this widget used in add post
        ProfilePictureWithStory(
          isWithoutStory: timePosted == null,
          image: image,
        ),
        const SizedBox(
          width: 5,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: FontsStyle.font18PopinMedium(),
              ),
              if (timePosted != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2.5),
                  child: Text(
                    timePosted!,
                    style: FontsStyle.font15Popin(
                      height: 1,
                      color: Colors.white60,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (timePosted != null)
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
      ],
    );
  }
}
