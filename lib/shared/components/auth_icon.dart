import 'package:flutter/material.dart';

import '../style/theme/constant.dart';

class AuthIcon extends StatelessWidget {
  const AuthIcon({
    super.key,
    required this.image,
  });
  final String image;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      width: 36,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            defaultColor,
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Center(
        child: Container(
          height: 32,
          width: 32,
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          child: Image.asset(
            image,
            height: 32,
          ),
        ),
      ),
    );
  }
}
