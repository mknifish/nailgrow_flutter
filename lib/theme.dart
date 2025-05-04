import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFE0E5EC); // ニューモーフィズム背景色
  static const Color accentColor = Color(0xFFFFCDC5); // アクセントカラー
  static const Color shadowLightColor = Colors.white; // 明るいシャドウ
  static const Color shadowDarkColor = Color(0xFFB0BEC5); // 暗いシャドウ

  static ThemeData get theme {
    return ThemeData(
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        secondary: accentColor,
      ),
      scaffoldBackgroundColor: primaryColor,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: accentColor),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: primaryColor,
        selectedItemColor: accentColor,
        unselectedItemColor: shadowDarkColor,
        elevation: 10,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: accentColor,
        circularTrackColor: shadowDarkColor,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: Colors.grey[800]), // 旧: bodyText1
        bodyMedium: TextStyle(color: Colors.grey[700]), // 旧: bodyText2
        titleLarge: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold), // 旧: headline6
      ),
    );
  }
}
