import 'package:flutter/material.dart';
import 'package:shohozkaz/core/constants.dart';
import 'package:shohozkaz/features/screen/pages/account_settings/account_settings.dart';
import 'package:shohozkaz/features/screen/pages/home.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shohozkaz/features/screen/pages/jobs/findjobs.dart';
import 'package:shohozkaz/features/screen/pages/jobs/myjobs.dart';

class BottomNavigation extends StatefulWidget {
  final Function(ThemeMode)? toggleTheme;
  final Function(Locale)? onLanguageChange;
  const BottomNavigation({super.key, this.toggleTheme, this.onLanguageChange});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int selectedIndex = 0;
  late final List<Widget> widgetOptions;

  @override
  void initState() {
    super.initState();
    widgetOptions = <Widget>[
      const Home(),
      FindJobsScreen(),
      MyJobsScreen(),
      AccountSettingsScreen(
        toggleTheme: widget.toggleTheme ?? (themeMode) {},
        onLanguageChange: widget.onLanguageChange ?? (locale) {},
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    var scaffold = Scaffold(
      body: IndexedStack(index: selectedIndex, children: widgetOptions),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.transparent,
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),

            child: Theme(
              data: Theme.of(context).copyWith(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                //splashFactory: NoSplash.splashFactory,
              ),
              child: BottomNavigationBar(
                currentIndex: selectedIndex,
                onTap: _onItemTapped,
                selectedItemColor: AppColors.button,
                unselectedItemColor: Colors.grey[700],
                elevation: 0,
                selectedFontSize: 16,
                unselectedFontSize: 12,
                type: BottomNavigationBarType.fixed,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Iconsax.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Iconsax.briefcase),
                    label: 'Find Job',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Iconsax.tick_square),
                    label: 'My Job',
                  ),

                  BottomNavigationBarItem(
                    icon: Icon(Iconsax.menu),
                    label: 'Menu',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return scaffold;
  }
}
