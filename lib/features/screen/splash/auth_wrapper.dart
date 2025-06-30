import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shohozkaz/features/screen/darktheme/testscreen1.dart';
import 'package:shohozkaz/features/screen/user_auth/login.dart';

class AuthWrapper extends StatelessWidget {
  final Function(ThemeMode)? toggleTheme;
  const AuthWrapper({super.key, this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          // Logged in → send to ThemeCheck
          return ThemeCheck(toggleTheme: toggleTheme);
        } else {
          // Not logged in
          return const LoginScreen();
        }
      },
    );
  }
}
