import 'package:flutter/material.dart';
import 'package:shohozkaz/core/constants.dart';
import 'package:shohozkaz/l10n/app_localizations.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
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
                  loc.forgotPasswordText,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 80),
                TextFormField(
                  controller: _emailController,
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

                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {

                      debugPrint("Email: ${_emailController.text}");

                      Navigator.pushNamed(context, '/login');
                    } else {
                      debugPrint(loc.failedValid);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor:
                        AppColors.button, // Use a defined color constant
                    shadowColor: Colors.transparent,
                  ),
                  child: Text(
                    loc.forgotPasswordText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Add a child widget here
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
