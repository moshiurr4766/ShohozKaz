

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shohozkaz/core/constants.dart';

class WorkerSetting extends StatefulWidget {
  final Function(ThemeMode) toggleTheme;
  final Function(Locale) onLanguageChange;

  const WorkerSetting({
    super.key,
    required this.toggleTheme,
    required this.onLanguageChange,
  });

  @override
  State<WorkerSetting> createState() => _WorkerSettingState();
}

class _WorkerSettingState extends State<WorkerSetting> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0E0E0E) : const Color(0xFFF5F5F7),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Account & Settings",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              _sectionTitle("Account"),
              _settingsTile(
                icon: Iconsax.category,
                label: "Overview",
                onTap: () => Navigator.pushNamed(context, '/dashboard'),
              ),
              _settingsTile(
                icon: Iconsax.shield_tick,
                label: "Verify Account",
                onTap: () => Navigator.pushNamed(context, '/workerverification'),
              ),

              const SizedBox(height: 16),

              _sectionTitle("Jobs"),
              _settingsTile(
                icon: Iconsax.timer,
                label: "Pending Jobs",
                onTap: () => Navigator.pushNamed(context, '/posterpendingjobs'),
              ),
              _settingsTile(
                icon: Iconsax.briefcase,
                label: "Manage Jobs",
                onTap: () => Navigator.pushNamed(context, '/updatejobsscreen'),
              ),
              _settingsTile(
                icon: Iconsax.add_square,
                label: "Create Job Post",
                onTap: () => Navigator.pushNamed(context, '/postjobs'),
              ),
              _settingsTile(
                icon: Iconsax.close_square,
                label: "Declined Jobs",
                onTap: () => Navigator.pushNamed(context, '/rejectedjobs'),
              ),

              const SizedBox(height: 16),

              _sectionTitle("Finance & Support"),
              _settingsTile(
                icon: Iconsax.wallet_3,
                label: "Earnings Wallet",
                onTap: () => Navigator.pushNamed(context, '/userwallet'),
              ),
              _settingsTile(
                icon: Iconsax.message_question,
                label: "Help & Support",
                onTap: () => Navigator.pushNamed(context, '/helpsupport'),
              ),

              const SizedBox(height: 16),

              _sectionTitle("System"),
              _settingsTile(
                icon: Iconsax.repeat,
                label: "Switch to Employer",
                onTap: () => Navigator.pushNamed(context, '/nav'),
              ),

              const SizedBox(height: 20),

              _themeSwitcher(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // STYLISH SECTION TITLE
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white70 : Colors.black87,
        ),
      ),
    );
  }

  // MODERN SETTINGS TILE
  Widget _settingsTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.button, size: 24),
        title: Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Icon(
          Iconsax.arrow_right_3,
          color: isDark ? Colors.white54 : Colors.black38,
        ),
        onTap: onTap,
      ),
    );
  }

  // SMOOTH THEME SWITCHER
  Widget _themeSwitcher() {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: SwitchListTile(
        value: isDark,
        activeColor: AppColors.button,
        title: Text(
          "Dark Mode",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        onChanged: (value) {
          setState(() => isDark = value);
          widget.toggleTheme(value ? ThemeMode.dark : ThemeMode.light);
        },
      ),
    );
  }
}
