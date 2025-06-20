import 'package:flutter/material.dart';
import 'package:shohozkaz/l10n/app_localizations.dart';

class LanguageSwitch extends StatelessWidget {


  final Function(Locale) onLanguageChange;
  const LanguageSwitch({super.key, required this.onLanguageChange});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      //appBar: AppBar(title: Text(loc.appTitle)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(loc.welcomeText),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => onLanguageChange(const Locale('en')),
              child: const Text('English'),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () => onLanguageChange(const Locale('bn')),
              child: const Text('বাংলা'),
            ),
          ],
        ),
      ),
    );
  }
  
  // final Function(Locale) onLanguageChange;

  // const LanguageSwitch({super.key, required this.onLanguageChange});

  // @override
  // Widget build(BuildContext context) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       ElevatedButton(
  //         onPressed: () => onLanguageChange(const Locale('en')),
  //         child: const Text('English'),
  //       ),
  //       const SizedBox(width: 12),
  //       ElevatedButton(
  //         onPressed: () => onLanguageChange(const Locale('bn')),
  //         child: const Text('বাংলা'),
  //       ),
  //     ],
  //   );
  // }
}
