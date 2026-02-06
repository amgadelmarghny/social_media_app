import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/shared/bloc/chat_cubit/chat_cubit.dart';
import 'package:social_media_app/shared/style/theme/constant.dart';

/// A horizontal preview bar of images picked to be sent in the chat message.
///
/// Displays selected image thumbnails with a remove (X) button overlay.
/// Only appears if at least one image is picked.
class CustomPickedImagesListView extends StatelessWidget {
  const CustomPickedImagesListView({super.key});

  @override
  Widget build(BuildContext context) {
    // Use BlocBuilder to react to changes in ChatCubit, especially UpdatePickedImagesState.
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        // Get the ChatCubit instance from context for access to pickedImages and removal logic.
        var cubit = context.read<ChatCubit>();

        // If there are no picked images, return an empty widget (don't show the preview bar).
        if (cubit.pickedImages.isEmpty) return const SizedBox.shrink();

        // Container to hold the horizontal list of picked images.
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: cubit.pickedImages.isNotEmpty
              ? 110
              : 0, // Fixed height for the preview images bar.
          padding: const EdgeInsets.only(
              left: 8, right: 8, top: 8), // Spacing around the images.
          decoration: BoxDecoration(
            color: defaultColor, // Slightly colored background for contrast.
            border: const Border(
                top:
                    BorderSide(color: Colors.black12)), // Top border separator.
          ),
          child: ListView.separated(
            scrollDirection: Axis.horizontal, // Show images side by side.
            itemCount:
                cubit.pickedImages.length, // Number of images to display.
            separatorBuilder: (context, index) =>
                const SizedBox(width: 10), // Space between images.
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  // Main image thumbnail, clipped with rounded corners.
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      cubit.pickedImages[index], // The selected image file.
                      height: 90,
                      width: 90,
                      fit: BoxFit
                          .cover, // Fills the box with the image (may crop).
                    ),
                  ),
                  // Small circular remove (X) icon at the top-right corner.
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      // On tap, remove the image from the picked list.
                      onTap: () => cubit.removeImageFromPreview(index),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
