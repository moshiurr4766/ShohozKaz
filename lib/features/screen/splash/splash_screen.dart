import 'dart:async';
import 'package:flutter/material.dart';
//import 'package:lottie/lottie.dart';
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

    // Delay for 3 seconds, then go to Login screen
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/');
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
            // App Logo
            //Image.asset('assets/images/logo/logo.png', height: 120),
            //const SizedBox(height: 20),
            // App Name
            //const CircularProgressIndicator(),
            
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
