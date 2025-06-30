
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shohozkaz/core/constants.dart';
import 'package:shohozkaz/l10n/app_localizations.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:shohozkaz/services/auth_service.dart';
import 'package:shohozkaz/services/store_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _obscureText = true;
  bool _acceptTrams = false;
  bool _showTermsError = false;
  bool _isLoading = false;
  String? _completePhoneNumber;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> registerAndStoreUserInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await authService.value.signUp(
        email: emailController.text,
        password: passwordController.text,
      );

      final uid = authService.value.currentUser?.uid;
      if (uid == null) throw Exception("UID is null after sign up");

      await storeService.value.storeUserData(
        uid: uid,
        name: nameController.text,
        email: emailController.text,
        phone: _completePhoneNumber ?? '',
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/');
    } on FirebaseAuthException catch (e) {
      debugPrint("Registration failed: ${e.message}");
    } on FirebaseException catch (e) {
      debugPrint("Firestore error: ${e.message}");
    } catch (e) {
      debugPrint("Unexpected error: $e");
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
                  loc.registerText,
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: actionColor,
                  ),
                ),
                const SizedBox(height: 80),

                // Name
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: loc.nameText,
                    labelStyle: TextStyle(color: actionColor),
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_2_outlined, color: actionColor),
                  ),
                  style: TextStyle(color: actionColor),
                  validator: (value) =>
                      value == null || value.isEmpty ? loc.enterName : null,
                ),

                const SizedBox(height: 20),

                // Email
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: loc.emailLabel,
                    labelStyle: TextStyle(color: actionColor),
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined, color: actionColor),
                  ),
                  style: TextStyle(color: actionColor),
                  validator: (value) {
                    if (value == null || value.isEmpty) return loc.enterEmail;
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return loc.enterEmailValid;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Phone
                IntlPhoneField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: loc.phoneText,
                    labelStyle: TextStyle(color: actionColor),
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(Icons.call_outlined, color: actionColor),
                  ),
                  style: TextStyle(color: actionColor),
                  initialCountryCode: 'BD',
                  onChanged: (phone) {
                    _completePhoneNumber = phone.completeNumber;
                  },
                ),

                const SizedBox(height: 20),

                // Password
                TextFormField(
                  controller: passwordController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    labelText: loc.passwordLabel,
                    labelStyle: TextStyle(color: actionColor),
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline, color: actionColor),
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
                  style: TextStyle(color: actionColor),
                  validator: (value) {
                    if (value == null || value.isEmpty) return loc.enterPass;
                    if (value.length < 6) return loc.enterPassValid;
                    return null;
                  },
                ),

                const SizedBox(height: 10),

                // Terms
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
                      child: Text(
                        loc.tcText,
                        style: TextStyle(
                          color: actionColor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),

                if (_showTermsError)
                  Padding(
                    padding: const EdgeInsets.only(left: 15, bottom: 10),
                    child: Text(
                      loc.acceptNText,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),

                // Submit button
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (!_acceptTrams) {
                            setState(() => _showTermsError = true);
                            return;
                          }

                          if (_formKey.currentState!.validate()) {
                            registerAndStoreUserInfo();
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
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          loc.registerText,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),

                const SizedBox(height: 5),

                // Already have an account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(loc.alreadyHaveAccount),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      child: Text(
                        loc.loginText,
                        style: TextStyle(color: actionColor),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // OR Divider
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

                // Google Sign Up
                ElevatedButton(
                  onPressed: () {
                    // TODO: Google Sign Up
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: actionColor, width: 2),
                  ),
                  child: FittedBox(
                    child: Row(
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









































// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:shohozkaz/core/constants.dart';
// import 'package:shohozkaz/l10n/app_localizations.dart';
// import 'package:intl_phone_field/intl_phone_field.dart';
// import 'package:shohozkaz/services/auth_service.dart';
// import 'package:shohozkaz/services/store_service.dart';

// class SignupScreen extends StatefulWidget {
//   const SignupScreen({super.key});

//   @override
//   State<SignupScreen> createState() => _SignupScreenState();
// }

// class _SignupScreenState extends State<SignupScreen> {
//   bool _obscureText = true;
//   bool _acceptTrams = false;
//   bool _showTermsError = false;
//   bool _isLoading = false;
//   String? _completePhoneNumber;

//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController phoneController = TextEditingController(); // 🔧 Added

//   @override
//   void dispose() {
//     nameController.dispose();
//     emailController.dispose();
//     passwordController.dispose();
//     phoneController.dispose(); // 🔧 Dispose added
//     super.dispose();
//   }

//   // ✅ New function that registers and stores user info sequentially
//   Future<void> registerAndStoreUserInfo() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       // 🔧 Sign up with Firebase
//       await authService.value.signUp(
//         email: emailController.text,
//         password: passwordController.text,
//       );

//       final uid = authService.value.currentUser?.uid;
//       if (uid == null) throw Exception("UID is null after sign up");

//       // 🔧 Store user data in Firestore
//       await storeService.value.storeUserData(
//         uid: uid,
//         name: nameController.text,
//         email: emailController.text,
//         phone: _completePhoneNumber ?? '',
//       );

//       if (!mounted) return;
//       Navigator.pushReplacementNamed(context, '/');
//     } on FirebaseAuthException catch (e) {
//       debugPrint("Registration failed: ${e.message}");
//     } on FirebaseException catch (e) {
//       debugPrint("Firestore error: ${e.message}");
//     } catch (e) {
//       debugPrint("Unexpected error: $e");
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
//                   loc.registerText,
//                   style: const TextStyle(
//                     fontSize: 34,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 80),

//                 // Name input
//                 TextFormField(
//                   controller: nameController,
//                   decoration: InputDecoration(
//                     labelText: loc.nameText,
//                     border: const OutlineInputBorder(),
//                     prefixIcon: Icon(
//                       Icons.person_2_outlined,
//                       color: Theme.of(context).primaryColor,
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return loc.enterName;
//                     }
//                     return null;
//                   },
//                 ),

//                 const SizedBox(height: 20),

//                 // Email input
//                 TextFormField(
//                   controller: emailController,
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

//                 const SizedBox(height: 20),

//                 // Phone number input
//                 IntlPhoneField(
//                   controller: phoneController,
//                   decoration: InputDecoration(
//                     labelText: loc.phoneText,
//                     border: const OutlineInputBorder(),
//                     prefixIcon: Icon(
//                       Icons.call_outlined,
//                       color: Theme.of(context).primaryColor,
//                     ),
//                   ),
//                   initialCountryCode: 'BD',
//                   onChanged: (phone) {
//                     _completePhoneNumber = phone.completeNumber;
//                   },
//                 ),

//                 const SizedBox(height: 20),

//                 // Password input
//                 TextFormField(
//                   controller: passwordController,
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
//                     if (value == null || value.isEmpty) {
//                       return loc.enterPass;
//                     }
//                     if (value.length < 6) {
//                       return loc.enterPassValid;
//                     }
//                     return null;
//                   },
//                 ),

//                 const SizedBox(height: 10),

//                 // Terms checkbox
//                 Row(
//                   children: [
//                     Checkbox(
//                       value: _acceptTrams,
//                       onChanged: (value) {
//                         setState(() {
//                           _acceptTrams = value ?? false;
//                           if (_acceptTrams) _showTermsError = false;
//                         });
//                       },
//                     ),
//                     Text(loc.acceptText),
//                     TextButton(
//                       onPressed: () {},
//                       child: Text(
//                         loc.tcText,
//                         style: TextStyle(
//                           color: Theme.of(context).primaryColor,
//                           decoration: TextDecoration.underline,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),

//                 if (_showTermsError)
//                   Padding(
//                     padding: const EdgeInsets.only(left: 15, bottom: 10),
//                     child: Text(
//                       loc.acceptNText,
//                       style: TextStyle(
//                         color: Theme.of(context).colorScheme.error,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ),

//                 // Register button
//                 ElevatedButton(
//                   onPressed: _isLoading
//                       ? null
//                       : () {
//                           if (!_acceptTrams) {
//                             setState(() {
//                               _showTermsError = true;
//                             });
//                             return;
//                           }

//                           if (_formKey.currentState!.validate()) {
//                             registerAndStoreUserInfo(); // ✅ Call new function
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
//                   ),
//                   child: _isLoading
//                       ? const CircularProgressIndicator(color: Colors.white)
//                       : Text(
//                           loc.registerText,
//                           style: TextStyle(
//                             color: Theme.of(context).colorScheme.onPrimary,
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                 ),

//                 const SizedBox(height: 5),

//                 // Already have account
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(loc.alreadyHaveAccount),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.pushNamed(context, '/login');
//                       },
//                       child: Text(
//                         loc.loginText,
//                         style: TextStyle(color: Theme.of(context).primaryColor),
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 15),

//                 // Divider
//                 Row(
//                   children: <Widget>[
//                     const Expanded(child: Divider(thickness: 2)),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                       child: Text(
//                         loc.orText,
//                         style: const TextStyle(color: Colors.grey),
//                       ),
//                     ),
//                     const Expanded(child: Divider(thickness: 2)),
//                   ],
//                 ),

//                 const SizedBox(height: 10),

//                 // Google sign up
//                 ElevatedButton(
//                   onPressed: () {
//                     // Handle Google Sign Up logic
//                   },
//                   style: ElevatedButton.styleFrom(
//                     minimumSize: const Size(double.infinity, 50),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     backgroundColor: Colors.white,
//                     side: BorderSide(
//                       color: Theme.of(context).primaryColor,
//                       width: 2,
//                     ),
//                   ),
//                   child: FittedBox(
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Image.asset(
//                           'assets/images/logo/google.png',
//                           height: 24,
//                           width: 24,
//                         ),
//                         const SizedBox(width: 8),
//                         Text(
//                           loc.googleSignUpText,
//                           style: const TextStyle(
//                             color: Colors.black,
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 10),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }








































