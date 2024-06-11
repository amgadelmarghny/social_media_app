import 'package:flutter/material.dart';

class ProfilePictureWithStory extends StatelessWidget {
  const ProfilePictureWithStory({super.key, required this.image});
  final String image;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85,
      padding: const EdgeInsets.all(14),
      width: 85,
      decoration: const ShapeDecoration(
        image: DecorationImage(
            image: AssetImage(
          'lib/assets/images/story_circular.png',
        )),
        shape: CircleBorder(),
      ),
      child: CircleAvatar(
        backgroundImage: NetworkImage(image),
      ),
    );
  }
}
