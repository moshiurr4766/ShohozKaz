import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shohozkaz/core/constants.dart';
import 'package:shohozkaz/l10n/app_localizations.dart';
import 'package:shohozkaz/services/auth_service.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  ///  Send reset email via Firebase
  Future<void> resetPassword() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await authService.value.resetPassword(
        email: _emailController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.resetSuccessText),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context); //  Go back to login screen
    } on FirebaseAuthException catch (e) {
      debugPrint("Error resetting password: $e");

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Reset failed'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    //  Set icon/text color dynamically based on theme
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color actionColor = isDark ? Colors.white : const Color.fromARGB(255, 0, 0, 0);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                ///  Page title
                Text(
                  loc.forgotPasswordText,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: actionColor, //  match theme color
                  ),
                ),

                const SizedBox(height: 80),

                ///  Email input
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: loc.emailLabel,
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: actionColor, // white for dark, blue for light
                    ),
                    labelStyle: TextStyle(color: actionColor), // label text color
                  ),
                  style: TextStyle(color: actionColor), //  input text color
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

                ///  Submit button
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            debugPrint("Email: ${_emailController.text}");
                            resetPassword();
                          } else {
                            debugPrint(loc.failedValid);
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
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          loc.forgotPasswordText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}























// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:shohozkaz/core/constants.dart';
// import 'package:shohozkaz/l10n/app_localizations.dart';
// import 'package:shohozkaz/services/auth_service.dart';

// class ForgotPassword extends StatefulWidget {
//   const ForgotPassword({super.key});

//   @override
//   State<ForgotPassword> createState() => _ForgotPasswordState();
// }

// class _ForgotPasswordState extends State<ForgotPassword> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   final TextEditingController _emailController = TextEditingController();

//   bool _isLoading = false;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     super.dispose();
//   }

//   Future<void> resetPassword() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       await authService.value.resetPassword(
//         email: _emailController.text.trim(),
//       );

//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(AppLocalizations.of(context)!.resetSuccessText),
//           backgroundColor: Colors.green,
//         ),
//       );

//       Navigator.pop(context); // Optional: Go back to login screen
//     } on FirebaseAuthException catch (e) {
//       debugPrint("Error resetting password: $e");

//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(e.message ?? 'Reset failed'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final loc = AppLocalizations.of(context)!;

//     return Scaffold(
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 Text(
//                   loc.forgotPasswordText,
//                   style: const TextStyle(
//                     fontSize: 32,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 80),

//                 TextFormField(
//                   controller: _emailController,
//                   decoration: InputDecoration(
//                     labelText: loc.emailLabel,
//                     border: const OutlineInputBorder(),
//                     prefixIcon: Icon(
//                       Icons.email_outlined,
//                       color: Theme.of(context).primaryColor,
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return loc.enterEmail;
//                     }
//                     if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
//                       return loc.enterEmailValid;
//                     }
//                     return null;
//                   },
//                 ),

//                 const SizedBox(height: 30),

//                 ElevatedButton(
//                   onPressed: _isLoading
//                       ? null
//                       : () {
//                           if (_formKey.currentState!.validate()) {
//                             debugPrint("Email: ${_emailController.text}");
//                             resetPassword();
//                           } else {
//                             debugPrint(loc.failedValid);
//                           }
//                         },
//                   style: ElevatedButton.styleFrom(
//                     minimumSize: const Size(double.infinity, 50),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     backgroundColor: AppColors.button,
//                     shadowColor: Colors.transparent,
//                   ),
//                   child: _isLoading
//                       ? const CircularProgressIndicator(color: Colors.white)
//                       : Text(
//                           loc.forgotPasswordText,
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

