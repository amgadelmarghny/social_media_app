import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:social_media_app/shared/components/image_viewer_screen.dart';

class CustomGradleImagesMessage extends StatelessWidget {
  const CustomGradleImagesMessage({
    super.key,
    required this.images,
  });

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true, // Enables GridView inside Column.
      physics: const NeverScrollableScrollPhysics(), // Disable inner scroll.
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        // Use 2 columns for 2+ images, or just 1.
        crossAxisCount: images.length >= 2 ? 2 : 1,
        crossAxisSpacing: 5, // Space horizontally between grid tiles.
        mainAxisSpacing: 5, // Space vertically between grid tiles.
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ImageViewerScreen(imageUrl: images[index]),
              ),
            );
          },
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(15), // Round corners for images.
            child: CachedNetworkImage(
              imageUrl: images[index], // The image URL for display.
              fit: BoxFit.cover, // Clip and zoom to fill box.
              placeholder: (context, url) => Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.white,
                  strokeWidth: 2,
                ),
              ),
              errorWidget: (context, url, error) => const HugeIcon(
                icon: HugeIconsStrokeRounded
                    .alert02, // Error icon if image fails.
              ),
            ),
          ),
        );
      },
    );
  }
}
