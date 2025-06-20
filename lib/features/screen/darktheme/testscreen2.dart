import 'package:flutter/material.dart';

class TestUi extends StatelessWidget {
  final Function(ThemeMode)? toggleTheme;

  const TestUi({super.key, this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test UI')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('This is a test UI', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/');
              },
              child: const Text('Go to LoginScreen'),
            ),
          ],
        ),
      ),
    );
  }
}
