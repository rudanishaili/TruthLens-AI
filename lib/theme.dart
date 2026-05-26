import 'package:flutter/material.dart';

class AppTheme {

  static ThemeData darkTheme = ThemeData(

    brightness: Brightness.dark,

    scaffoldBackgroundColor: const Color(0xff0B1220),

    primaryColor: Colors.cyanAccent,

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xff111827),
      centerTitle: true,
      elevation: 0,
    ),

    colorScheme: ColorScheme.dark(
      primary: Colors.cyanAccent,
      secondary: Colors.cyan,
    ),

    textTheme: const TextTheme(

      headlineLarge: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),

      bodyLarge: TextStyle(
        fontSize: 18,
        color: Colors.white70,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(

      style: ElevatedButton.styleFrom(

        backgroundColor: Colors.cyanAccent,
        foregroundColor: Colors.black,

        padding: const EdgeInsets.symmetric(
          horizontal: 30,
          vertical: 16,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
  );
}