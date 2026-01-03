import 'package:flutter/material.dart';
import 'package:social_media_app/shared/components/bottom_bar_cilper.dart';

/// Custom painter to draw shadow and border for the bottom navigation bar.
class BottomBarShadowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Get the custom path (shape) from the BottomBarClipper.
    Path path = BottomBarClipper().getClip(size);

    // Draw the shadow following the bar contour.
    canvas.drawShadow(
        path,
        Colors.black.withValues(alpha: 0.3), // Shadow color and opacity.
        8.0, // Blur radius of the shadow.
        false // The shadow is not transparent.
        );

    // Draw the purple border around the navigation bar for decoration.
    Paint paint = Paint()
      ..color = const Color(0xffBA85E8) // Purple border color.
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0; // Border width.

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
