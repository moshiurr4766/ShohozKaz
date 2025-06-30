// import 'package:flutter/material.dart';

// class AppThemes {
//   static final ThemeData lightTheme = ThemeData(
//     brightness: Brightness.light,
//     colorScheme: const ColorScheme.light(
//       primary: Colors.green,
//       onPrimary: Colors.white,
//       // ignore: deprecated_member_use
//       background: Colors.white,
//       // ignore: deprecated_member_use
//       onBackground: Colors.black87,
//       secondary: Colors.greenAccent,
//     ),
//     scaffoldBackgroundColor: Colors.white,
//     fontFamily: 'Roboto',
//     appBarTheme: const AppBarTheme(
//       backgroundColor: Colors.white,
//       foregroundColor: Colors.black,
//       elevation: 2,
//       centerTitle: true,
//     ),
//     textTheme: Typography.blackMountainView.copyWith(
//       bodyLarge: const TextStyle(fontSize: 16, color: Colors.black87),
//       titleLarge: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//     ),
//     iconTheme: const IconThemeData(color: Colors.black87),
//     elevatedButtonTheme: ElevatedButtonThemeData(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.green,
//         foregroundColor: Colors.white,
//         textStyle: const TextStyle(fontWeight: FontWeight.bold),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.all(Radius.circular(12)),
//         ),
//       ),
//     ),
//     inputDecorationTheme: InputDecorationTheme(
//       filled: true,
//       fillColor: Colors.grey.shade100,
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: BorderSide.none,
//       ),
//       hintStyle: TextStyle(color: Colors.grey.shade600),
//     ),
//     cardTheme: CardThemeData(
//       color: Colors.white,
//       elevation: 4,
//       margin: const EdgeInsets.all(8),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//     ),
//     snackBarTheme: const SnackBarThemeData(
//       backgroundColor: Colors.green,
//       contentTextStyle: TextStyle(color: Colors.white),
//       behavior: SnackBarBehavior.floating,
//     ),
//   );

//   static final ThemeData darkTheme = ThemeData(
//     brightness: Brightness.dark,
//     colorScheme: const ColorScheme.dark(
//       primary: Colors.green,
//       onPrimary: Colors.white,
//       // ignore: deprecated_member_use
//       background: Color(0xFF121212),
//       // ignore: deprecated_member_use
//       onBackground: Colors.white70,
//       secondary: Colors.greenAccent,
//     ),
//     scaffoldBackgroundColor: const Color(0xFF121212),
//     fontFamily: 'Roboto',
//     appBarTheme: const AppBarTheme(
//       backgroundColor: Colors.black,
//       foregroundColor: Colors.white,
//       elevation: 2,
//       centerTitle: true,
//     ),
//     textTheme: Typography.whiteMountainView.copyWith(
//       bodyLarge: const TextStyle(fontSize: 16, color: Colors.white70),
//       titleLarge: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
//     ),
//     iconTheme: const IconThemeData(color: Colors.white70),
//     elevatedButtonTheme: ElevatedButtonThemeData(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.green,
//         foregroundColor: Colors.white,
//         textStyle: const TextStyle(fontWeight: FontWeight.bold),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.all(Radius.circular(12)),
//         ),
//       ),
//     ),
//     inputDecorationTheme: InputDecorationTheme(
//       filled: true,
//       fillColor: Colors.grey.shade800,
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: BorderSide.none,
//       ),
//       hintStyle: TextStyle(color: Colors.grey.shade400),
//     ),
//     cardTheme: CardThemeData(
//       color: Colors.grey.shade900,
//       elevation: 4,
//       margin: const EdgeInsets.all(8),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//     ),
//     snackBarTheme: const SnackBarThemeData(
//       backgroundColor: Colors.green,
//       contentTextStyle: TextStyle(color: Colors.white),
//       behavior: SnackBarBehavior.floating,
//     ),
//   );
// }








//Code 2

// import 'package:flutter/material.dart';

// class AppThemes {
//   static final ThemeData lightTheme = ThemeData(
//     brightness: Brightness.light,
//     primarySwatch: Colors.green,
//     fontFamily: 'Roboto',
//     scaffoldBackgroundColor: Colors.white,
//     appBarTheme: const AppBarTheme(
//       backgroundColor: Colors.white,
//       foregroundColor: Colors.black,
//     ),
//     textTheme: const TextTheme(
//       bodyLarge: TextStyle(fontSize: 18, color: Colors.black),
//       titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//     ),
//     iconTheme: const IconThemeData(color: Colors.black),
//   );

//   static final ThemeData darkTheme = ThemeData(
//     brightness: Brightness.dark,
//     primarySwatch: Colors.green,
//     fontFamily: 'Roboto',
//     scaffoldBackgroundColor: const Color(0xFF121212),
//     appBarTheme: const AppBarTheme(
//       backgroundColor: Color.fromARGB(255, 31, 31, 31),
//       foregroundColor: Colors.white,
//     ),
//     textTheme: const TextTheme(
//       bodyLarge: TextStyle(fontSize: 18, color: Colors.white),
//       titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
//     ),
//     iconTheme: const IconThemeData(color: Colors.white),
//   );
// }














import 'package:flutter/material.dart';

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Roboto',
    scaffoldBackgroundColor: Colors.white,
    colorScheme: const ColorScheme.light(
      primary: Color.fromARGB(255, 2, 14, 249),
      onPrimary: Colors.white,
      background: Colors.white,
      onBackground: Colors.black,
      secondary: Colors.greenAccent,
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
      primary: Colors.white,
      onPrimary: Colors.black,
      background: Color(0xFF121212),
      onBackground: Colors.white,
      secondary: Colors.greenAccent,
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
