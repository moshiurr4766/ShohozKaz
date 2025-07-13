import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shohozkaz/core/constants.dart';
import 'package:shohozkaz/l10n/app_localizations.dart';
import 'package:shohozkaz/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;
  bool _isLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await authService.value.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/nav');
    } on FirebaseAuthException catch (e) {
      debugPrint("Error signing in: ${e.message}");

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Login failed')),
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

    // Determine color based on theme brightness
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
                Text(
                  loc.loginText,
                  style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 80),

                //  Email field
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: loc.emailLabel,
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: actionColor, 
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return loc.enterEmail;
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return loc.enterEmailValid;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    labelText: loc.passwordLabel,
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: actionColor, 
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: actionColor, 
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return loc.enterPass;
                    if (value.length < 6) return loc.enterPassValid;
                    return null;
                  },
                ),

                const SizedBox(height: 5),

                //  Forgot Password Button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/forgot');
                    },
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(actionColor), 
                      overlayColor: MaterialStateProperty.all(Colors.transparent),
                      splashFactory: NoSplash.splashFactory,
                    ),
                    child: Text(loc.forgotPassword),
                  ),
                ),

                //Login Button
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            login();
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
                          loc.loginButton,
                          style: TextStyle(
                            color: AppColors.buttonText,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),

                const SizedBox(height: 15),

                // ✅ Sign Up redirect
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(loc.dontHaveAccount),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all(actionColor),
                        overlayColor: MaterialStateProperty.all(Colors.transparent),
                        splashFactory: NoSplash.splashFactory,
                      ),
                      child: Text(
                        loc.registerText,
                        style: TextStyle(color: actionColor), // ✅ color match
                      ),
                    ),
                  ],
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

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   bool _obscureText = true;
//   bool _isLoading = false;

//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   Future<void> login() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       await authService.value.signIn(
//         email: _emailController.text.trim(),
//         password: _passwordController.text.trim(),
//       );

//       if (!mounted) return;
//       Navigator.pushReplacementNamed(context, '/'); // or your home page
//     } on FirebaseAuthException catch (e) {
//       debugPrint("Error signing in: ${e.message}");

//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.message ?? 'Login failed')),
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
//                   loc.loginText,
//                   style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 80),

//                 // Email field
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
//                     if (value == null || value.isEmpty) return loc.enterEmail;
//                     if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
//                       return loc.enterEmailValid;
//                     }
//                     return null;
//                   },
//                 ),

//                 const SizedBox(height: 30),

//                 // Password field
//                 TextFormField(
//                   controller: _passwordController,
//                   obscureText: _obscureText,
//                   decoration: InputDecoration(
//                     labelText: loc.passwordLabel,
//                     border: const OutlineInputBorder(),
//                     prefixIcon: Icon(
//                       Icons.lock_outline,
//                       color: Theme.of(context).primaryColor,
//                     ),
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _obscureText
//                             ? Icons.visibility_off_outlined
//                             : Icons.visibility_outlined,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           _obscureText = !_obscureText;
//                         });
//                       },
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) return loc.enterPass;
//                     if (value.length < 6) return loc.enterPassValid;
//                     return null;
//                   },
//                 ),

//                 const SizedBox(height: 5),

//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: TextButton(
//                     onPressed: () {
//                       Navigator.pushNamed(context, '/forgot');
//                     },
//                     style: ButtonStyle(
//                       // ignore: deprecated_member_use
//                       foregroundColor: MaterialStateProperty.all(
//                         Theme.of(context).primaryColor,
//                       ),
//                       // ignore: deprecated_member_use
//                       overlayColor: MaterialStateProperty.all(Colors.transparent),
//                       splashFactory: NoSplash.splashFactory,
//                     ),
//                     child: Text(loc.forgotPassword),
//                   ),
//                 ),

//                 // Login button
//                 ElevatedButton(
//                   onPressed: _isLoading
//                       ? null
//                       : () {
//                           if (_formKey.currentState!.validate()) {
//                             login();
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
//                           loc.loginButton,
//                           style: TextStyle(
//                             color: AppColors.buttonText,
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                 ),

//                 const SizedBox(height: 15),

//                 // Register redirect
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(loc.dontHaveAccount),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.pushNamed(context, '/signup');
//                       },
//                       style: ButtonStyle(
//                         foregroundColor: WidgetStateProperty.all(
//                           Theme.of(context).primaryColor,
//                         ),
//                         overlayColor: WidgetStateProperty.all(
//                           Colors.transparent,
//                         ),
//                         splashFactory: NoSplash.splashFactory,
//                       ),
//                       child: Text(
//                         loc.registerText,
//                         style: TextStyle(color: Theme.of(context).primaryColor),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

