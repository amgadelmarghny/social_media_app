import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/constant.dart';

abstract class FontsStyle {
  static TextStyle font15Popin(
      {Color color = Colors.white, bool isOverFlow = false, double? height}) {
    return GoogleFonts.poppins(
      textStyle: TextStyle(
        height: height,
        color: color,
        fontSize: 15,
        overflow: isOverFlow ? TextOverflow.ellipsis : null,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  static TextStyle font18Popin(
      {Color color = Colors.white, bool isShadow = false}) {
    return GoogleFonts.poppins(
      textStyle: TextStyle(
        color: color,
        fontSize: 18,
        overflow: TextOverflow.ellipsis,
        fontWeight: color != Colors.white ? FontWeight.w500 : null,
        shadows: isShadow
            ? [
                const Shadow(
                  blurRadius: 5,
                  offset: Offset(1, 1),
                  color: Colors.black38,
                )
              ]
            : null,
      ),
    );
  }

  static TextStyle font18PopinBold() {
    return GoogleFonts.poppins(
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        overflow: TextOverflow.ellipsis,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  static TextStyle font20Poppins = GoogleFonts.poppins(
    textStyle: const TextStyle(
      fontSize: 20,
      height: 1,
      color: Colors.white60,
    ),
  );

  static TextStyle font20BoldWithColor = GoogleFonts.poppins(
    textStyle: const TextStyle(
      fontSize: 20,
      overflow: TextOverflow.ellipsis,
      fontWeight: FontWeight.w600,
      color: defaultColor,
    ),
  );

  static TextStyle font22Bold({Color color = Colors.white}) {
    return TextStyle(
      fontSize: 22,
      color: color,
      fontWeight: FontWeight.bold,
    );
  }

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

  static const TextStyle font32Bold = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle font35Bold = GoogleFonts.poppins(
    textStyle: const TextStyle(
      fontSize: 35,
      height: 1,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  );

  static const TextStyle font36BoldShadow = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    shadows: [
      Shadow(
        blurRadius: 10,
        offset: Offset(0, 2),
        color: Colors.black38,
      ),
    ],
  );
}
