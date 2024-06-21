import 'package:flutter/material.dart';
import 'package:popover/popover.dart';
import '../../../shared/components/profile_picture_with_story.dart';
import 'cover_image_menu_items.dart';
import 'profile_image_menu_items.dart';

class CustomCoverAndImageProfile extends StatelessWidget {
  const CustomCoverAndImageProfile({
    super.key,
    required this.profileImage,
    required this.profileCover,
  });
  final String profileImage;
  final String? profileCover;

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
            child: GestureDetector(
              onTap: () {
                showPopover(
                    backgroundColor: const Color(0xff8862D9),
                    height: 100,
                    width: 250,
                    context: context,
                    bodyBuilder: (context) => const CoverImageMenuItem());
              },
              child: Image.network(
                fit: BoxFit.cover,
                profileCover ??
                    'https://as1.ftcdn.net/v2/jpg/02/70/09/98/1000_F_270099822_9zbx236dHn1hyxYNl9HSOBvpUEpU0eOz.jpg',
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: width / 2 - 50,
            child: GestureDetector(
              onTap: () {
                showPopover(
                    backgroundColor: const Color(0xff8862D9),
                    height: 150,
                    width: 250,
                    context: context,
                    bodyBuilder: (context) => const ProfileImageMenuItem());
              },
              child: ProfilePictureWithStory(
                size: 100,
                image: profileImage,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
