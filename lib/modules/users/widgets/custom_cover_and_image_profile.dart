import 'package:flutter/material.dart';
import '../../../shared/components/profile_picture_with_story.dart';

class CustomCoverAndImageProfile extends StatelessWidget {
  const CustomCoverAndImageProfile({
    super.key,
    required this.profileImage,
    required this.profileCover,
  });
  final String profileImage;
  final String profileCover;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    double width = MediaQuery.sizeOf(context).width;
    return Padding(
      padding: const EdgeInsets.only(bottom: 50),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
            height: height * 0.3,
            width: double.infinity,
            child: Image.network(
              fit: BoxFit.cover,
              profileCover,
            ),
          ),
          Positioned(
            bottom: -50,
            right: width / 2 - 50,
            child: ProfilePictureWithStory(
              size: 100,
              image: profileImage,
            ),
          ),
        ],
      ),
    );
  }
}
