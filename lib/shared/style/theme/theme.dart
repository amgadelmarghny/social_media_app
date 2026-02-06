import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:social_media_app/shared/style/theme/constant.dart';
import '../fonts/font_style.dart';

abstract class CustomThemeMode {
  static final lightTheme = ThemeData(
    tabBarTheme: TabBarThemeData(
      indicatorColor: Colors.white, // ✅ Correct location
    ),
    primaryColor: defaultTextColor,
    scaffoldBackgroundColor: Colors.transparent,
    iconTheme: const IconThemeData(color: Colors.white),
    searchBarTheme: SearchBarThemeData(
      textStyle: WidgetStateProperty.resolveWith(
          (states) => FontsStyle.font18PopinWithShadowOption()),
      hintStyle: WidgetStateProperty.resolveWith(
          (states) => FontsStyle.font18PopinWithShadowOption()),
      backgroundColor:
          WidgetStateProperty.resolveWith((states) => const Color(0xff635A8F)),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        iconColor: WidgetStateProperty.resolveWith((states) => Colors.white),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: Color(0xff635A8F),
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: TextStyle(fontSize: 0),
      unselectedLabelStyle: TextStyle(fontSize: 0),
      showSelectedLabels: false,
      showUnselectedLabels: false,
    ),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      backgroundColor: Colors.transparent,
      titleTextStyle: FontsStyle.font20Poppins.copyWith(color: Colors.white),
      systemOverlayStyle: const SystemUiOverlayStyle(
        systemStatusBarContrastEnforced: true,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      shape: CircleBorder(),
      backgroundColor: defaultColorButton,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );

  static final darkTheme = ThemeData(
    primaryColor: defaultTextColor,
    scaffoldBackgroundColor: Colors.transparent,
    iconTheme: const IconThemeData(color: Colors.white),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        iconColor: WidgetStateProperty.resolveWith((states) => Colors.white),
      ),
    ),
    searchBarTheme: SearchBarThemeData(
      hintStyle: WidgetStateProperty.resolveWith(
          (states) => FontsStyle.font18PopinWithShadowOption()),
      backgroundColor:
          WidgetStateProperty.resolveWith((states) => const Color(0xff635A8F)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: Color(0xff635A8F),
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: TextStyle(fontSize: 0),
      unselectedLabelStyle: TextStyle(fontSize: 0),
      showSelectedLabels: false,
      showUnselectedLabels: false,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      titleTextStyle: FontsStyle.font20Poppins.copyWith(color: Colors.white),
      centerTitle: true,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      shape: CircleBorder(),
      backgroundColor: defaultColorButton,
      iconSize: 35,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}

BoxDecoration themeColor() {
  return const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        defaultTextColor,
        Color(0xff8862D9),
        Color(0xff986DDD),
        Color(0xffA878E2),
        Color(0xffA878E2),
        Color(0xffA878E2),
        Color(0xffC58DEB),
        Color(0xffC58DEB),
        Color(0xffD197ED),
        Color(0xffcfbadb),
        Colors.white,
      ],
    ),
  );
}
