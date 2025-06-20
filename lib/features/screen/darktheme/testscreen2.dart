import 'package:flutter/material.dart';
import 'package:shohozkaz/l10n/app_localizations.dart';

class TestUi extends StatelessWidget {
  final Function(ThemeMode)? toggleTheme;

  const TestUi({super.key, this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: const Text('Test UI')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(loc.uiText, style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/');
              },
              child: const Text('Go to LoginScreen'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/language');
              },
              child: const Text('Language Switch'),
            ),
          ],
        ),
      ),
    );
  }
}
