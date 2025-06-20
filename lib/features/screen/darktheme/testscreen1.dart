import 'package:flutter/material.dart';
import 'package:shohozkaz/l10n/app_localizations.dart';

class LoginScreen extends StatelessWidget {
  final Function(ThemeMode)? toggleTheme;
  
  const LoginScreen({super.key, this.toggleTheme});

  @override
  Widget build(BuildContext context) {

    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.appTitle)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(loc.welcomeText),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => toggleTheme?.call(ThemeMode.light),
              child: const Text("Switch to Light Theme"),
            ),
            ElevatedButton(
              onPressed: () => toggleTheme?.call(ThemeMode.dark),
              child: const Text("Switch to Dark Theme"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/test'),
              child: const Text("System Default"),
            ),
          ],
        ),
      ),
    );
  }
}
