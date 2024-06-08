import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract class CustomThemeMode {
  static final lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.transparent,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: Color(0xff635A8F),
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: TextStyle(fontSize: 0),
      unselectedLabelStyle: TextStyle(fontSize: 0),
      showSelectedLabels: false,
      showUnselectedLabels: false,
    ),
    appBarTheme: const AppBarTheme(
      toolbarHeight: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      shape: CircleBorder(),
      backgroundColor: Color(0xff635A8F),
    ),
  );

  static final darkTheme = ThemeData(
    scaffoldBackgroundColor: Colors.transparent,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: Color(0xff635A8F),
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: TextStyle(fontSize: 0),
      unselectedLabelStyle: TextStyle(fontSize: 0),
      showSelectedLabels: false,
      showUnselectedLabels: false,
    ),
    appBarTheme: const AppBarTheme(
      toolbarHeight: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      shape: CircleBorder(),
      backgroundColor: Color(0xff635A8F),
    ),
  );
}

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
