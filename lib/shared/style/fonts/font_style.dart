import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../size_configs.dart';
import '../theme/constant.dart';

abstract class FontsStyle {
  static TextStyle font15Popin(
      {Color color = Colors.white, bool isOverFlow = false, double? height}) {
    return GoogleFonts.poppins(
      textStyle: TextStyle(
        height: height,
        color: color,
        fontSize: getResponsiveFontSize(fontSize: 15),
        overflow: isOverFlow ? TextOverflow.ellipsis : null,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  static TextStyle font18Popin(
      {Color color = Colors.white,
      bool isShadow = false,
      bool isOverflow = true}) {
    return GoogleFonts.poppins(
      textStyle: TextStyle(
        color: color,
        fontSize: getResponsiveFontSize(fontSize: 18),
        overflow: isOverflow ? TextOverflow.ellipsis : null,
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

  static TextStyle font18PopinMedium() {
    return GoogleFonts.poppins(
      textStyle: TextStyle(
        color: Colors.white,
        fontSize: getResponsiveFontSize(fontSize: 18),
        overflow: TextOverflow.ellipsis,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  static TextStyle font20Poppins = GoogleFonts.poppins(
    textStyle: TextStyle(
      fontSize: getResponsiveFontSize(fontSize: 20),
      height: 1,
      color: Colors.white60,
    ),
  );

  static TextStyle font20BoldWithColor = GoogleFonts.poppins(
    textStyle: TextStyle(
      fontSize: getResponsiveFontSize(fontSize: 20),
      overflow: TextOverflow.ellipsis,
      fontWeight: FontWeight.w600,
      color: defaultTextColor,
    ),
  );

  static TextStyle font22Bold(
      {Color color = Colors.white, double fontSize = 22}) {
    return TextStyle(
      fontSize: getResponsiveFontSize(fontSize: fontSize),
      color: color,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle font21ColorBold = TextStyle(
    fontSize: getResponsiveFontSize(fontSize: 21),
    color: Color(0xff6D4ACD),
    fontWeight: FontWeight.w800,
    overflow: TextOverflow.ellipsis,
  );

  static TextStyle font24Shadow = TextStyle(
    fontSize: getResponsiveFontSize(fontSize: 24),
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
  static TextStyle font25Bold = TextStyle(
    fontSize: getResponsiveFontSize(fontSize: 25),
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  static TextStyle font32Bold = TextStyle(
    fontSize: getResponsiveFontSize(fontSize: 32),
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle font35Bold = GoogleFonts.poppins(
    textStyle: TextStyle(
      fontSize: getResponsiveFontSize(fontSize: 35),
      height: 1,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  );

  static TextStyle font36BoldShadow = TextStyle(
    fontSize: getResponsiveFontSize(fontSize: 36),
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

double getResponsiveFontSize({required double fontSize}) {
  double scaleFactor = getScaleFactor();
  double responsiveFontSize = fontSize * scaleFactor;

  double minFontSize = fontSize * 0.8;
  double maxFontSize = fontSize * 1.2;
  return responsiveFontSize.clamp(minFontSize, maxFontSize);
}

double getScaleFactor() {
  //double width = MediaQuery.sizeOf(context).width;
  var platFormDispatcher = PlatformDispatcher.instance;
  var physicalWidth = platFormDispatcher.views.first.physicalSize.width;
  var pixelRatio = platFormDispatcher.views.first.devicePixelRatio;
  double width = physicalWidth / pixelRatio;

  if (width < SizeConfigs.tabletSizeWidth) {
    // font size for mobile
    return width / 420;
  } else {
    // font size for tablet
    return width / 1000;
  }
}
