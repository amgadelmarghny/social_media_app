import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProfilePictureWithStory extends StatelessWidget {
  const ProfilePictureWithStory(
      {super.key,
      required this.image,
      this.size = 85,
      this.isWithoutStory = false});
  final String? image;
  final double size;
  final bool isWithoutStory;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      padding: const EdgeInsets.all(4),
      width: size,
      decoration: !isWithoutStory
          ? const BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.fill,
                image: AssetImage(
                  'lib/assets/images/story_circular.png',
                ),
              ),
            )
          : null,
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: image != null
            ? CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: image!,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(
                    Icons.error_outline,
                    size: 30,
                    color: Colors.red,
                  ),
                ),
              )
            : Center(
                child: Icon(
                  Icons.person,
                  color: Colors.grey.shade600,
                  // if size != 85 that's mean the widget is in edit profile
                  size: size == 85 ? 65 : 80,
                ),
              ),
      ),
    );
  }
}
