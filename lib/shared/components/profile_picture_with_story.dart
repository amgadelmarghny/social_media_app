import 'package:flutter/material.dart';

class ProfilePictureWithStory extends StatelessWidget {
  const ProfilePictureWithStory({
    super.key,
    required this.image,
    this.size = 85,
  });
  final String? image;
  final double size;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      padding: const EdgeInsets.all(4),
      width: size,
      decoration: const BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.fill,
          image: AssetImage(
            'lib/assets/images/story_circular.png',
          ),
        ),
      ),
      child: CircleAvatar(
        backgroundImage: image != null ? NetworkImage(image!) : null,
        child: image != null
            ? null
            :  Center(
                child: Icon(
                  Icons.person,
                  color: Colors.grey.shade600,
                  size: size == 85? 65:80,
                ),
              ),
      ),
    );
  }
}
