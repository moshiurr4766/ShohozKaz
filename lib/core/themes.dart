




import 'package:flutter/material.dart';

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Roboto',
    scaffoldBackgroundColor: Colors.white,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFFFF5C2A), // Updated: Orange for buttons, focus, etc.
      onPrimary: Colors.white,
      background: Colors.white,
      onBackground: Colors.black,
      secondary: Color(0xFFFFAB40), // Optional soft orange accent
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 18, color: Colors.black),
      titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    ),
    iconTheme: const IconThemeData(color: Colors.black),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Roboto',
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFFF5C2A), // Updated: Orange for buttons, focus, etc.
      onPrimary: Colors.black,
      background: Color(0xFF121212),
      onBackground: Colors.white,
      secondary: Color(0xFFFFAB40),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromARGB(255, 31, 31, 31),
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 18, color: Colors.white),
      titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
    ),
    iconTheme: const IconThemeData(color: Colors.white),
  );
}
