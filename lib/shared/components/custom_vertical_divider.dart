import 'package:flutter/material.dart';

class CustomVerticalDivider extends StatelessWidget {
  const CustomVerticalDivider({
    super.key,
    this.height = 55,
  });
  final double height;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      width: 2,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 15),
    );
  }
}
