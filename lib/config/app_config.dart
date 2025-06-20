import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
//import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shohozkaz/l10n/app_localizations.dart';

import '../core/themes.dart';
import 'router.dart';

class ShohozKazApp extends StatefulWidget {
  const ShohozKazApp({super.key});

  @override
  State<ShohozKazApp> createState() => _ShohozKazAppState();
}

class _ShohozKazAppState extends State<ShohozKazApp> {
  ThemeMode _themeMode = ThemeMode.system; // Light, Dark, or System
  Locale _locale = const Locale('en'); // Default to English

  // Method to toggle theme
  void _toggleTheme(ThemeMode newMode) {
    setState(() {
      _themeMode = newMode;
    });
  }

  // Method to change language
  void _changeLocale(Locale newLocale) {
    setState(() {
      _locale = newLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShohozKaz',
      debugShowCheckedModeBanner: false,

      // Themes
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: _themeMode,

      // Localization
      locale: _locale,
      supportedLocales: const [
        Locale('en'), // English
        Locale('bn'), // Bangla
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Navigation
      initialRoute: '/',
      onGenerateRoute: (settings) =>
          AppRouter.generateRoute(settings, _toggleTheme, _changeLocale),
    );
  }
}







// import 'package:flutter/material.dart';
// import '../core/themes.dart';
// import 'router.dart';

// class ShohozKazApp extends StatefulWidget {
//   const ShohozKazApp({super.key});

//   @override
//   State<ShohozKazApp> createState() => _ShohozKazAppState();
// }

// class _ShohozKazAppState extends State<ShohozKazApp> {
//   ThemeMode _themeMode = ThemeMode.system; // default to system

//   void _toggleTheme(ThemeMode newMode) {
//     setState(() {
//       _themeMode = newMode;
//     });
//   }
  
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'ShohozKaz',
//       debugShowCheckedModeBanner: false,
//       // Theme setup
//       theme: AppThemes.lightTheme,
//       darkTheme: AppThemes.darkTheme,
//       themeMode: _themeMode,

//       // Localization setup

//       initialRoute: '/',
//       onGenerateRoute: (settings) =>
//           AppRouter.generateRoute(settings, _toggleTheme),
//     );
//   }
// }
