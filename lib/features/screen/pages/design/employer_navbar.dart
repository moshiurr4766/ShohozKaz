import 'package:flutter/material.dart';
import 'package:shohozkaz/core/constants.dart';
import 'package:shohozkaz/features/screen/pages/account_settings/account_settings.dart';
import 'package:shohozkaz/features/screen/pages/home.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shohozkaz/features/screen/pages/jobs/findjobs.dart';
import 'package:shohozkaz/features/screen/pages/jobs/applyjobs/employer_jobs.dart';

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
      const FindJobsScreen(),
      const MyJobsScreen(),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: widgetOptions),
      bottomNavigationBar: Padding(
        //padding: const EdgeInsets.all(0),
        padding: const EdgeInsets.all(12),
        child: Container(
          decoration: BoxDecoration(
            //borderRadius: BorderRadius.circular(0),
            borderRadius: BorderRadius.circular(30),
            color: isDark ? Colors.grey[900] : Colors.white,
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.1),
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
              ),
              child: BottomNavigationBar(
                backgroundColor: Colors.transparent, // ✅ rely on container bg
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
                    icon: Icon(Iconsax.home_2),
                    label: 'Explore',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Iconsax.search_normal),
                    label: 'Find Jobs',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Iconsax.briefcase),
                    label: 'My Jobs',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Iconsax.user),
                    label: 'Account',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
