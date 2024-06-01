import 'package:flutter/material.dart';

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
            Color(0xff3B21B2),
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
