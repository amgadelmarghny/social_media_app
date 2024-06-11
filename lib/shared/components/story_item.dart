import 'package:flutter/material.dart';
import 'package:social_media_app/shared/components/profile_picture_with_story.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';

class StoryItem extends StatelessWidget {
  const StoryItem({super.key, required this.image, required this.firstName});
  final String image;
  final String firstName;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: Column(
        children: [
          ProfilePictureWithStory(image: image),
          const SizedBox(
            height: 5,
          ),
          Text(
            firstName,
            style: FontsStyle.font15Popin(isOverFlow: true),
          )
        ],
      ),
    );
  }
}