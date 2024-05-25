import 'package:flutter/material.dart';

abstract class FontsStyle {
  static const TextStyle font36Bold = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    shadows: [
      Shadow(blurRadius: 10, offset: Offset(0, 2), color: Colors.black38)
    ],
  );
  static const TextStyle font20 = TextStyle(
    fontSize: 24,
    color: Colors.white,
    fontWeight: FontWeight.normal,
    shadows: [
      Shadow(
        blurRadius: 10,
        offset: Offset(0, 2),
        color: Colors.black38,
      ),
    ],
  );
  static const TextStyle font22Blod = TextStyle(
    fontSize: 22,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );
}
