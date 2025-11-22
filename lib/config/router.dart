import 'package:flutter/material.dart';
import 'package:shohozkaz/features/screen/darktheme/testscreen1.dart';
import 'package:shohozkaz/features/screen/darktheme/testscreen2.dart';
import 'package:shohozkaz/features/screen/onboard_screen/onboard.dart';
import 'package:shohozkaz/features/screen/pages/account_settings/account_settings.dart';
import 'package:shohozkaz/features/screen/pages/chatscreen/chat_home.dart';
import 'package:shohozkaz/features/screen/pages/design/employer_navbar.dart';
import 'package:shohozkaz/features/screen/pages/help_support/help_support.dart';
import 'package:shohozkaz/features/screen/pages/home.dart';
import 'package:shohozkaz/features/screen/pages/jobs/applyjobs/pendingjobs/pending_jobs.dart';
import 'package:shohozkaz/features/screen/pages/jobs/applyjobs/pendingjobs/rejected_jobs_screen.dart';
import 'package:shohozkaz/features/screen/pages/jobs/findjobs.dart';
import 'package:shohozkaz/features/screen/pages/jobs/applyjobs/employer_jobs.dart';
import 'package:shohozkaz/features/screen/pages/jobs/postjobs.dart';
import 'package:shohozkaz/features/screen/pages/jobs/updatejobs/update_jobs.dart';
import 'package:shohozkaz/features/screen/pages/profile/deshboard.dart';
import 'package:shohozkaz/features/screen/pages/wallet/user_wallet.dart';
import 'package:shohozkaz/features/screen/pages/design/worker_navbar.dart';
import 'package:shohozkaz/features/screen/pages/worker_account/kycscreen/worker_kyc.dart';
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
      case '/nav':
        return MaterialPageRoute(
          builder: (_) => BottomNavigation(
            toggleTheme: toggleTheme,
            onLanguageChange: changeLocale, 
          ),
        );

      case '/workernavbar':
        return MaterialPageRoute(
          builder: (_) => WorkerNavBar(
            toggleTheme: toggleTheme,
            onLanguageChange: changeLocale, 
          ),
        );

      case '/home':
        return MaterialPageRoute(builder: (_) => const Home());

      case '/theme':
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
      case '/onboarding':
        return MaterialPageRoute(builder: (_) => const JobOnboardingScreen());
      case '/findjobs':
        return MaterialPageRoute(builder: (_) => const FindJobsScreen());
      case '/postjobs':
        return MaterialPageRoute(builder: (_) => const CreateJobScreen());
      case '/myjobs':
        return MaterialPageRoute(builder: (_) => const MyJobsScreen());
      case '/dashboard':
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case '/userwallet':
        return MaterialPageRoute(builder: (_) => MyWalletScreen());
      case '/settings':
        return MaterialPageRoute(builder: (_) => AccountSettingsScreen(
          toggleTheme: toggleTheme ?? (mode) {},
          onLanguageChange: changeLocale ?? (locale) {},
        ));
      case '/wrapper':
        return MaterialPageRoute(
          builder: (_) => AuthWrapper(toggleTheme: toggleTheme),
        );
      case '/Plumbing':
        return MaterialPageRoute(
          builder: (_) => ThemeCheck(toggleTheme: toggleTheme ?? (mode) {}),
        );

      case '/chathome':
        return MaterialPageRoute(
          builder: (_) =>  ChatHomeScreen(),
        ); 
      case '/updatejobsscreen':
        return MaterialPageRoute(builder: (_) => const UpdateJobsScreen()); 


      case '/userpendingjobs':
        return MaterialPageRoute(builder: (_) => const PendingJobsScreen(isUser: true,));
      case '/posterpendingjobs':
        return MaterialPageRoute(builder: (_) => const PendingJobsScreen(isUser: false,));
      case '/rejectedjobs':
        return MaterialPageRoute(builder: (_) => const RejectedJobsScreen());

      case '/workerverification':
        return MaterialPageRoute(builder: (_) => const KycWizard());

      case '/helpsupport':
        return MaterialPageRoute(builder: (_) => const SupportHubScreen());

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Page not found'))),
        );
    }
  }
}
