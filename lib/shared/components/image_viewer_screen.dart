import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// A full-screen image viewer that supports interactive zoom and pan.
/// Shows a single image fetched from a URL. Best for photo preview in chat, galleries, etc.
class ImageViewerScreen extends StatelessWidget {
  /// The URL of the image to be displayed.
  final String imageUrl;

  /// Creates the image viewer. Requires [imageUrl].
  const ImageViewerScreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Professional solid black background for focus on image
      appBar: AppBar(
        backgroundColor: Colors.black, // App bar matches background for seamless look
        iconTheme: const IconThemeData(color: Colors.white), // White icons for contrast
      ),
      body: Center(
        // Center the image and allow zoom/pan with InteractiveViewer
        child: InteractiveViewer(
          panEnabled: true, // Allow user to pan (drag) the image when zoomed in
          minScale: 0.5, // Minimum scale factor for zooming out
          maxScale: 4.0, // Maximum scale factor for zooming in
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit
                .contain, // Show the whole image, keep aspect ratio, no cropping
            // Show an error icon in case the image fails to load
            errorWidget: (context, url, error) =>
                const Icon(Icons.error, color: Colors.white),
          ),
        ),
      ),
    );
  }
}