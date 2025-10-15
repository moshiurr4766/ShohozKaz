import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shohozkaz/core/constants.dart';
import 'package:shohozkaz/features/screen/pages/account_settings/worker_setting.dart';
import 'package:shohozkaz/features/screen/pages/jobs/applyjobs/worker_jobs.dart';
import 'package:shohozkaz/features/screen/pages/worker_account/worker_home.dart';

class WorkerNavBar extends StatefulWidget {
  final Function(ThemeMode)? toggleTheme;
  final Function(Locale)? onLanguageChange;
  const WorkerNavBar({super.key, this.toggleTheme, this.onLanguageChange});

  @override
  State<WorkerNavBar> createState() => _WorkerNavBarState();
}

class _WorkerNavBarState extends State<WorkerNavBar> {
  int selectedIndex = 0;
  late final List<Widget> widgetOptions;

  @override
  void initState() {
    super.initState();
    widgetOptions = <Widget>[
      const WorkerHome(),
      const WorkerJobsScreen(),
      WorkerSettingsScreen(
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
                backgroundColor: Colors.transparent,
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
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Iconsax.briefcase),
                    label: 'My Jobs',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Iconsax.profile_circle),
                    label: 'Profile',
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
