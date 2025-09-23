import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class DisplayPostImage extends StatelessWidget {
  const DisplayPostImage({super.key, required this.postImage});
  final String postImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(1.3),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(25)),
      ),
      child: Container(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(25)),
        ),
        child: CachedNetworkImage(
          fit: BoxFit.fitHeight,
          width: double.infinity,
          imageUrl: postImage,
          // Show a loading indicator while the image loads.
          placeholder: (context, url) => const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: CircularProgressIndicator(),
            ),
          ),
          // Show an error icon if the image fails to load.
          errorWidget: (context, url, error) => const Center(
            child: Icon(
              Icons.error_outline,
              size: 30,
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }
}
