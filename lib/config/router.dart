import 'package:flutter/material.dart';
import 'package:shohozkaz/features/screen/darktheme/testscreen1.dart';
import 'package:shohozkaz/features/screen/darktheme/testscreen2.dart';
import 'package:shohozkaz/widgets/language_switch.dart';

class AppRouter {
  static Route<dynamic> generateRoute(
    RouteSettings settings,
    Function(ThemeMode)? toggleTheme,
    Function(Locale)? changeLocale,
  ) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => LoginScreen(toggleTheme: toggleTheme ?? (mode) {}),
        );

      case '/language':
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Language Settings')),
            body: Center(
              child: LanguageSwitch(
                onLanguageChange: changeLocale ?? (locale) {},
              ),
            ),
          ),
        );

      case '/test':
        return MaterialPageRoute(builder: (_) => const TestUi());

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Page not found'))),
        );
    }
  }
}

// import 'package:flutter/material.dart';
// import 'package:shohozkaz/features/screen/darktheme/testscreen1.dart';
// import 'package:shohozkaz/features/screen/darktheme/testscreen2.dart';
// import 'package:shohozkaz/widgets/language_switch.dart';

// class AppRouter {
//   static Route<dynamic> generateRoute(RouteSettings settings, Function(ThemeMode)? toggleTheme,Function(Locale)? changeLocale) {
//   switch (settings.name) {
//     case '/':
//       return MaterialPageRoute(
//         builder: (_) => LoginScreen(
//           toggleTheme: toggleTheme,
//         ),
//       );
//     case '/language':
//       return MaterialPageRoute(
//         builder: (_) => LanguageSwitch(
//           onLanguageChange: changeLocale ?? (locale) {},
//         ),
//       );
//     case '/test':
//       return MaterialPageRoute(
//         builder: (_) => TestUi(),
//       );
//     default:
//       return MaterialPageRoute(
//         builder: (_) => const Scaffold(
//           body: Center(child: Text('Page not found')),
//         ),
//       );
//   }
// }

// }
