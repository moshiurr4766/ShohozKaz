import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shohozkaz/l10n/app_localizations.dart';

import '../core/themes.dart';
import 'router.dart';

class ShohozKazApp extends StatefulWidget {
  const ShohozKazApp({super.key});

  @override
  State<ShohozKazApp> createState() => _ShohozKazAppState();
}

class _ShohozKazAppState extends State<ShohozKazApp> {
  ThemeMode _themeMode = ThemeMode.system; // default theme mode
  Locale _locale = const Locale('en');      //  default language

  @override
  void initState() {
    super.initState();
    _loadPreferences(); // Load saved theme and language
  }

  // Load saved user preferences from SharedPreferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    //  Load theme
    final theme = prefs.getString('themeMode') ?? 'system';
    setState(() {
      switch (theme) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        default:
          _themeMode = ThemeMode.system;
      }
    });

    //  Load language
    final languageCode = prefs.getString('languageCode') ?? 'en';
    setState(() {
      _locale = Locale(languageCode);
    });
  }

  ///  Save and apply selected theme
  void _toggleTheme(ThemeMode newMode) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _themeMode = newMode;
    });

    //  Save selected theme to local storage
    switch (newMode) {
      case ThemeMode.light:
        prefs.setString('themeMode', 'light');
        break;
      case ThemeMode.dark:
        prefs.setString('themeMode', 'dark');
        break;
      default:
        prefs.setString('themeMode', 'system');
    }
  }

  ///  Save and apply selected language
  void _changeLocale(Locale newLocale) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _locale = newLocale;
    });

    //  Save selected language to local storage
    prefs.setString('languageCode', newLocale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShohozKaz',
      debugShowCheckedModeBanner: false,

      //  Apply themes
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: _themeMode,

      //  Localization settings
      locale: _locale,
      supportedLocales: const [
        Locale('en'),
        Locale('bn'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      //  Pass theme and locale change methods via route
      initialRoute: '/splash',
      onGenerateRoute: (settings) =>
          AppRouter.generateRoute(settings, _toggleTheme, _changeLocale),
    );
  }
}
