import 'dart:async';
import 'package:flutter/material.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:shohozkaz/l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      // final user = FirebaseAuth.instance.currentUser;
      // if (user != null) {
      //   Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      // } else {
      //   Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      // }
      Navigator.pushNamedAndRemoveUntil(context, '/wrapper', (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/animations/loading/handshake.gif', height: 280),
            Text(
              loc.appTitle,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
