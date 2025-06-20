
import 'package:flutter/material.dart';
import 'package:shohozkaz/features/screen/darktheme/testscreen1.dart';
import 'package:shohozkaz/features/screen/darktheme/testscreen2.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings, Function(ThemeMode)? toggleTheme) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(
        builder: (_) => LoginScreen(
          toggleTheme: toggleTheme,
        ),
      );
    case '/test':
      return MaterialPageRoute(
        builder: (_) => TestUi(),
      );
    default:
      return MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(child: Text('Page not found')),
        ),
      );
  }
}

}
