import 'package:flutter/material.dart';

class BottomBarClipper extends CustomClipper<Path> {
  BottomBarClipper(this.context, {required this.height});
  final BuildContext context;
  final double height;
  @override
  Path getClip(Size size) {
    final path = Path();
    final width = size.width;
    final heightValue = size.height;

    // FAB size is 56x56, so we need a curve that accommodates it
    // The curve should create a smooth notch in the top center for the FAB
    final fabRadius = 28.0; // Half of FAB size (56/2)
    final curveHeight =
        heightValue * 0.5; // Height of the curve notch (50% of height - deeper)
    final centerX = width / 2;

    // Corner radius values
    final topCornerRadius = 50.0; // Top corners radius
    final bottomCornerRadius = 100.0; // Bottom corners radius

    // Start from top left (before rounded corner)
    path.moveTo(0, topCornerRadius);

    // Top left rounded corner (outward/convex) - control point outside bounds
    path.quadraticBezierTo(
      -topCornerRadius, 0, // Control point (outside, creates convex curve)
      topCornerRadius, 0, // End point
    );

    // Draw flat top edge until curve starts - perfectly symmetrical
    final curveWidth =
        fabRadius * 2.8; // Total width of the curve (symmetrical)
    final curveStartX = centerX - curveWidth;
    final curveEndX = centerX + curveWidth;
    path.lineTo(curveStartX, 0);

    // Create smooth left curve downward using cubic bezier with sharper transition
    final curveBottomLeftX = centerX - fabRadius * 0.9;
    path.cubicTo(
      centerX -
          fabRadius * 2.3, // First control point X (wider for smoother start)
      0, // First control point Y (at top for smooth transition)
      centerX - fabRadius * 1.5, // Second control point X
      curveHeight * 0.5, // Second control point Y (mid curve - sharper)
      curveBottomLeftX, // End point X (left bottom of curve)
      curveHeight, // End point Y (bottom of left curve - deeper)
    );

    // Create the bottom center curve (the notch bottom) - perfectly centered and deeper
    final curveBottomRightX = centerX + fabRadius * 0.9;
    path.cubicTo(
      centerX - fabRadius * 0.4, // First control point X
      curveHeight * 1.15, // First control point Y (notch bottom - deeper)
      centerX + fabRadius * 0.4, // Second control point X (symmetrical)
      curveHeight * 1.15, // Second control point Y (notch bottom - deeper)
      curveBottomRightX, // End point X (right bottom of curve)
      curveHeight, // End point Y
    );

    // Create smooth right curve upward using cubic bezier with sharper transition
    path.cubicTo(
      centerX + fabRadius * 1.5, // First control point X (symmetrical to left)
      curveHeight * 0.5, // First control point Y (mid curve - sharper)
      centerX + fabRadius * 2.3, // Second control point X (symmetrical to left)
      0, // Second control point Y (at top for smooth transition)
      curveEndX, // End point X
      0, // End point Y
    );

    // Draw flat top edge to the end (before top right corner)
    path.lineTo(width - topCornerRadius, 0);

    // Top right rounded corner (outward/convex) - control point outside bounds
    path.quadraticBezierTo(
      width + topCornerRadius,
      0, // Control point (outside, creates convex curve)
      width, topCornerRadius, // End point
    );

    // Draw right edge (before bottom right corner)
    path.lineTo(width, heightValue - bottomCornerRadius);

    // Bottom right rounded corner (outward/convex) - control point outside bounds
    path.quadraticBezierTo(
      width,
      heightValue +
          bottomCornerRadius, // Control point (outside, creates convex curve)
      width - bottomCornerRadius, heightValue, // End point
    );

    // Draw bottom edge (before bottom left corner)
    path.lineTo(bottomCornerRadius, heightValue);

    // Bottom left rounded corner (outward/convex) - control point outside bounds
    path.quadraticBezierTo(
      -bottomCornerRadius,
      heightValue, // Control point (outside, creates convex curve)
      0, heightValue - bottomCornerRadius, // End point
    );

    // Draw left edge (back to start)
    path.lineTo(0, topCornerRadius);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
