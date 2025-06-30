import 'package:flutter/material.dart';
import 'package:shohozkaz/l10n/app_localizations.dart';
import 'package:shohozkaz/services/auth_service.dart';

class ThemeCheck extends StatefulWidget {
  const ThemeCheck({super.key, this.toggleTheme});
  final Function(ThemeMode)? toggleTheme;

  @override
  State<ThemeCheck> createState() => _ThemeCheckState();
}

class _ThemeCheckState extends State<ThemeCheck> {
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
              onPressed: () => widget.toggleTheme?.call(ThemeMode.light),
              child: const Text("Switch to Light Theme"),
            ),
            ElevatedButton(
              onPressed: () => widget.toggleTheme?.call(ThemeMode.dark),
              child: const Text("Switch to Dark Theme"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/test'),
              child: const Text("System Default"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/language'),
              child: const Text("Change Language"),
            ),

            ElevatedButton(
              onPressed: () async => {
                await authService.value.signOut(),
                // ignore: use_build_context_synchronously
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false),

              },
              child: const Text("Sign Out"),
            ),
          ],
        ),
      ),
    );
  }
}

