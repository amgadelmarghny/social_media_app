import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class FontsStyle {
  static const TextStyle font36BoldShadow = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    shadows: [
      Shadow(blurRadius: 10, offset: Offset(0, 2), color: Colors.black38)
    ],
  );
  static const TextStyle font24Shadow = TextStyle(
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
  static TextStyle font20Popin({Color color = Colors.white}) {
    return GoogleFonts.poppins(
      textStyle: TextStyle(
        color: color,
        fontSize: 19,
      ),
    );
  }
}
