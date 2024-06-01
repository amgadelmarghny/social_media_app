import 'package:flutter/material.dart';

BoxDecoration themeColor() {
  return const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xff3B21B2),
        Color(0xff8862D9),
        Color(0xff986DDD),
        Color(0xffA878E2),
        Color(0xffC58DEB),
        Color(0xffC58DEB),
        Color(0xffC58DEB),
        Color(0xffC58DEB),
        Color(0xffD197ED),
        Color(0xffcfbadb),
        Colors.white,
      ],
    ),
  );
}
