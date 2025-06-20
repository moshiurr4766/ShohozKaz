// // app_config.dart

// import 'package:flutter/material.dart';
// import '../core/themes.dart';
// import '../config/router.dart'; // Ensure this path matches where AppRouter is defined

// class ShohozKazApp extends StatelessWidget {
//   const ShohozKazApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'ShohozKaz',
//       debugShowCheckedModeBanner: false,
//       theme: AppThemes.lightTheme,
//       darkTheme: AppThemes.darkTheme,
//       themeMode: ThemeMode.system,
//       initialRoute: '/',
//       onGenerateRoute: AppRouter.generateRoute,
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../core/themes.dart';
import 'router.dart';

class ShohozKazApp extends StatefulWidget {
  const ShohozKazApp({super.key});

  @override
  State<ShohozKazApp> createState() => _ShohozKazAppState();
}

class _ShohozKazAppState extends State<ShohozKazApp> {
  ThemeMode _themeMode = ThemeMode.system; // default to system

  void _toggleTheme(ThemeMode newMode) {
    setState(() {
      _themeMode = newMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShohozKaz',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: _themeMode,
      initialRoute: '/',
      onGenerateRoute: (settings) =>
          AppRouter.generateRoute(settings, _toggleTheme),
    );
  }
}
