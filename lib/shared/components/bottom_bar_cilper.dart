import 'package:flutter/material.dart';

class BottomBarClipper extends CustomClipper<Path> {
  BottomBarClipper(this.context, {required this.hight});
  final BuildContext context;
  final double hight;
  @override
  Path getClip(Size size) {
    Path path = Path();
    final double xScaling =
        size.width / (MediaQuery.sizeOf(context).width - 20);
    final double yScaling = size.height / hight;
    path.lineTo(0 * xScaling, 27.5585 * yScaling);
    path.cubicTo(
      0 * xScaling,
      20.8153 * yScaling,
      3.39801 * xScaling,
      14.526 * yScaling,
      9.03817 * xScaling,
      10.8301 * yScaling,
    );
    path.cubicTo(
      9.03817 * xScaling,
      10.8301 * yScaling,
      15.5802 * xScaling,
      6.54326 * yScaling,
      15.5802 * xScaling,
      6.54326 * yScaling,
    );
    path.cubicTo(
      22.0951 * xScaling,
      2.27413 * yScaling,
      29.7147 * xScaling,
      0 * yScaling,
      37.5038 * xScaling,
      0 * yScaling,
    );
    path.cubicTo(
      37.5038 * xScaling,
      0 * yScaling,
      62.6607 * xScaling,
      0 * yScaling,
      62.6607 * xScaling,
      0 * yScaling,
    );
    path.cubicTo(
      62.6607 * xScaling,
      0 * yScaling,
      124.988 * xScaling,
      0 * yScaling,
      124.988 * xScaling,
      0 * yScaling,
    );
    path.cubicTo(
      136.364 * xScaling,
      0 * yScaling,
      147.203 * xScaling,
      4.84444 * yScaling,
      154.791 * xScaling,
      13.321 * yScaling,
    );
    path.cubicTo(
      154.791 * xScaling,
      13.321 * yScaling,
      171.832 * xScaling,
      32.3575 * yScaling,
      171.832 * xScaling,
      32.3575 * yScaling,
    );
    path.cubicTo(
      187.683 * xScaling,
      50.0651 * yScaling,
      215.386 * xScaling,
      50.1276 * yScaling,
      231.318 * xScaling,
      32.4917 * yScaling,
    );
    path.cubicTo(
      231.318 * xScaling,
      32.4917 * yScaling,
      248.756 * xScaling,
      13.1868 * yScaling,
      248.756 * xScaling,
      13.1868 * yScaling,
    );
    path.cubicTo(
      256.34 * xScaling,
      4.79119 * yScaling,
      267.125 * xScaling,
      0 * yScaling,
      278.439 * xScaling,
      0 * yScaling,
    );
    path.cubicTo(
      278.439 * xScaling,
      0 * yScaling,
      327.59 * xScaling,
      0 * yScaling,
      327.59 * xScaling,
      0 * yScaling,
    );
    path.cubicTo(
      327.59 * xScaling,
      0 * yScaling,
      350.9 * xScaling,
      0 * yScaling,
      350.9 * xScaling,
      0 * yScaling,
    );
    path.cubicTo(
      358.117 * xScaling,
      0 * yScaling,
      365.2 * xScaling,
      1.95284 * yScaling,
      371.398 * xScaling,
      5.65152 * yScaling,
    );
    path.cubicTo(
      371.398 * xScaling,
      5.65152 * yScaling,
      380.249 * xScaling,
      10.9336 * yScaling,
      380.249 * xScaling,
      10.9336 * yScaling,
    );
    path.cubicTo(
      386.296 * xScaling,
      14.5425 * yScaling,
      390 * xScaling,
      21.0657 * yScaling,
      390 * xScaling,
      28.1079 * yScaling,
    );
    path.cubicTo(
      390 * xScaling,
      28.1079 * yScaling,
      390 * xScaling,
      36 * yScaling,
      390 * xScaling,
      36 * yScaling,
    );
    path.cubicTo(
      390 * xScaling,
      58.0914 * yScaling,
      372.091 * xScaling,
      76 * yScaling,
      350 * xScaling,
      76 * yScaling,
    );
    path.cubicTo(
      350 * xScaling,
      76 * yScaling,
      40 * xScaling,
      76 * yScaling,
      40 * xScaling,
      76 * yScaling,
    );
    path.cubicTo(
      17.9086 * xScaling,
      76 * yScaling,
      0 * xScaling,
      58.0914 * yScaling,
      0 * xScaling,
      36 * yScaling,
    );
    path.cubicTo(
      0 * xScaling,
      36 * yScaling,
      0 * xScaling,
      27.5585 * yScaling,
      0 * xScaling,
      27.5585 * yScaling,
    );
    path.cubicTo(
      0 * xScaling,
      27.5585 * yScaling,
      0 * xScaling,
      27.5585 * yScaling,
      0 * xScaling,
      27.5585 * yScaling,
    );
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
