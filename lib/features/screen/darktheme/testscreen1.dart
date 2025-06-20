import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  final Function(ThemeMode)? toggleTheme;

  const LoginScreen({super.key, this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Welcome to ShohozKaz!"),
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
