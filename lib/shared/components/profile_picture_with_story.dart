import 'package:flutter/material.dart';

class ProfilePictureWithStory extends StatelessWidget {
  const ProfilePictureWithStory({
    super.key,
    required this.image,
    this.size = 85,
  });
  final String image;
  final double size;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      padding: const EdgeInsets.all(6),
      width: size,
      decoration: const ShapeDecoration(
        image: DecorationImage(
          fit: BoxFit.fill,
          image: AssetImage(
            'lib/assets/images/story_circular.png',
          ),
        ),
        shape: CircleBorder(),
      ),
      child: CircleAvatar(
        backgroundImage: NetworkImage(image),
      ),
    );
  }
}
