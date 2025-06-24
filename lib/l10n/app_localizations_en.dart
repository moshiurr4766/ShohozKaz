// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ShohozKaz';

  @override
  String get welcomeText => 'Welcome to ShohozKaz!';

  @override
  String get switchLanguage => 'Switch Language';

  @override
  String get uiText => 'This is a test UI';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get loginButton => 'Login';

  @override
  String get loginText => 'Login';

  @override
  String get noAccountRegister => 'Don’t have an account? Register';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get registerButton => 'Sign Up';
}
