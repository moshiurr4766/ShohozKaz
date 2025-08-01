import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shohozkaz/features/screen/onboard_screen/onboard.dart';
import 'package:shohozkaz/features/screen/pages/design/nav.dart';

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
          return BottomNavigation(toggleTheme: toggleTheme);
        } else {
          return const JobOnboardingScreen();
        }
      },
    );
  }
}
