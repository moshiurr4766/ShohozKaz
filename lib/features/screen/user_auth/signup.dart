import 'package:flutter/material.dart';
import 'package:shohozkaz/core/constants.dart';
import 'package:shohozkaz/l10n/app_localizations.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _obscureText = true;
  bool _acceptTrams = false;
  bool _showTermsError = false;
  String? _completePhoneNumber;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  loc.registerText,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 80),

                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: loc.nameText,
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.person_2_outlined,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return loc.enterName;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: loc.emailLabel,
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return loc.enterEmail;
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return loc.enterEmailValid;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                /// Phone number with country code
                IntlPhoneField(
                  decoration: InputDecoration(
                    labelText: loc.phoneText,
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.call_outlined,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  initialCountryCode: 'BD',
                  onChanged: (phone) {
                    _completePhoneNumber = phone.completeNumber;
                  },
                ),

                const SizedBox(height: 20),

                TextFormField(
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    labelText: loc.passwordLabel,
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: Theme.of(context).primaryColor,
                    ),
                    suffixIcon: Material(
                      type: MaterialType.transparency,
                      child: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return loc.enterPass;
                    }
                    if (value.length < 6) {
                      return loc.enterPassValid;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Checkbox(
                      value: _acceptTrams,
                      onChanged: (value) {
                        setState(() {
                          _acceptTrams = value ?? false;
                          if (_acceptTrams) _showTermsError = false;
                        });
                      },
                    ),
                    Text(loc.acceptText),
                    TextButton(
                      onPressed: () {},
                      style: ButtonStyle(
                        foregroundColor: WidgetStateProperty.all(
                          Theme.of(context).primaryColor,
                        ),
                        overlayColor: WidgetStateProperty.all(
                          Colors.transparent,
                        ),
                        splashFactory: NoSplash.splashFactory,
                      ),
                      child: Text(
                        loc.tcText,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),

                if (_showTermsError)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 15.0,
                      top: 4.0,
                      bottom: 10.0,
                    ),
                    child: Text(
                      loc.acceptNText,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),

                ElevatedButton(
                  onPressed: () {
                    if (!_acceptTrams) {
                      setState(() {
                        _showTermsError = true;
                      });
                      return;
                    }

                    if (_formKey.currentState!.validate()) {
                      debugPrint("Name: ${nameController.text}");
                      debugPrint("Email: ${emailController.text}");
                      debugPrint("Phone: $_completePhoneNumber");
                      debugPrint("Password: ${passwordController.text}");

                      Navigator.pushNamed(context, '/login');
                    } else {
                      debugPrint(
                        loc.failedValid,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: AppColors.button,
                    shadowColor: Colors.transparent,
                  ),
                  child: Text(
                    loc.registerText,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(loc.alreadyHaveAccount),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      style: ButtonStyle(
                        foregroundColor: WidgetStateProperty.all(
                          Theme.of(context).primaryColor,
                        ),
                        overlayColor: WidgetStateProperty.all(
                          Colors.transparent,
                        ),
                        splashFactory: NoSplash.splashFactory,
                      ),
                      child: Text(
                        loc.loginText,
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),
                Row(
                  children: <Widget>[
                    const Expanded(child: Divider(thickness: 2)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        loc.orText,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                    const Expanded(child: Divider(thickness: 2)),
                  ],
                ),

                const SizedBox(height: 10),

                ElevatedButton(
                  onPressed: () {
                    // Handle Google Sign Up logic
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    side: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                  ),
                  child: FittedBox(
                    fit:BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/logo/google.png',
                          height: 24,
                          width: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          loc.googleSignUpText,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
