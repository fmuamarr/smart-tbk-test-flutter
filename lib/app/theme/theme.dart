import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFED1C24);
  static const Color darkColor = Color(0xFF1A1A1A);
  static const Color backgroundColor = Colors.white;
  static const Color textColor = Colors.white;
  static const Color cardColor = Color(0xFFF5F6FA);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: textColor,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: darkColor,
        surface: cardColor,
        onPrimary: textColor,
        onSecondary: textColor,
      ),
      cardColor: cardColor,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: textColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(color: darkColor, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: darkColor),
        bodyMedium: TextStyle(color: darkColor.withAlpha(140)),
        labelLarge: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
      ),
      iconTheme: IconThemeData(color: primaryColor),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
