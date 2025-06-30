import 'package:flutter/material.dart';
import 'package:shohozkaz/features/screen/darktheme/testscreen1.dart';
import 'package:shohozkaz/features/screen/darktheme/testscreen2.dart';
import 'package:shohozkaz/features/screen/splash/auth_wrapper.dart';
import 'package:shohozkaz/features/screen/splash/splash_screen.dart';
import 'package:shohozkaz/features/screen/user_auth/forgot_pass.dart';
import 'package:shohozkaz/features/screen/user_auth/signup.dart';
import 'package:shohozkaz/features/screen/user_auth/login.dart';
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
          builder: (_) => ThemeCheck(toggleTheme: toggleTheme ?? (mode) {}),
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
      case '/splash':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/signup':
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case '/forgot':
        return MaterialPageRoute(builder: (_) => const ForgotPassword());
      case '/wrapper':
        return MaterialPageRoute(builder: (_) => AuthWrapper(toggleTheme: toggleTheme));

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
// import 'package:shohozkaz/features/screen/splash/auth_wrapper.dart';
// import 'package:shohozkaz/features/screen/splash/splash_screen.dart';
// import 'package:shohozkaz/features/screen/user_auth/forgot_pass.dart';
// import 'package:shohozkaz/features/screen/user_auth/signup.dart';
// import 'package:shohozkaz/features/screen/user_auth/login.dart';
// import 'package:shohozkaz/widgets/language_switch.dart';

// class AppRouter {
//   static Route<dynamic> generateRoute(
//     RouteSettings settings,
//     Function(ThemeMode)? toggleTheme,
//     Function(Locale)? changeLocale,
//   ) {
//     switch (settings.name) {
//       case '/':
//         return MaterialPageRoute(
//           builder: (_) => AuthWrapper(toggleTheme: toggleTheme),
//         );

//       case '/language':
//         return MaterialPageRoute(
//           builder: (_) => Scaffold(
//             appBar: AppBar(title: const Text('Language Settings')),
//             body: Center(
//               child: LanguageSwitch(
//                 onLanguageChange: changeLocale ?? (locale) {},
//               ),
//             ),
//           ),
//         );

//       case '/test':
//         return MaterialPageRoute(builder: (_) => const TestUi());
//       case '/splash':
//         return MaterialPageRoute(builder: (_) => const SplashScreen());
//       case '/login':
//         return MaterialPageRoute(builder: (_) => const LoginScreen());
//       case '/signup':
//         return MaterialPageRoute(builder: (_) => const SignupScreen());
//       case '/forgot':
//         return MaterialPageRoute(builder: (_) => const ForgotPassword());
//       case '/wrapper':
//         return MaterialPageRoute(
//           builder: (_) => AuthWrapper(toggleTheme: toggleTheme),
//         );

//       default:
//         return MaterialPageRoute(
//           builder: (_) => const Scaffold(
//             body: Center(child: Text('Page not found')),
//           ),
//         );
//     }
//   }
// }
