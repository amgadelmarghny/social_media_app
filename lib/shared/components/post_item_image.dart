import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PostItemImage extends StatelessWidget {
  const PostItemImage({
    super.key,
    required this.postImage,
  });

  final String postImage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Container(
        padding: const EdgeInsets.all(1.3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Container(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
          ),
          child: CachedNetworkImage(
            fit: BoxFit.fitHeight,
            width: double.infinity,
            imageUrl: postImage,
            placeholder: (context, url) => const Center(
                child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: CircularProgressIndicator(),
            )),
            errorWidget: (context, url, error) => const Center(
              child: Icon(
                Icons.error_outline,
                size: 30,
                color: Colors.red,
              ),
            ),
          ),
        ),
      ),
    );
  }
}