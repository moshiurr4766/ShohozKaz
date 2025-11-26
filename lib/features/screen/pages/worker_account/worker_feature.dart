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
    final brightness = Theme.of(context).brightness;
    isDark = brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Account & Settings"),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),

            _sectionTitle("Account"),
            _tile(
              Iconsax.category,
              "Overview",
              () => Navigator.pushNamed(context, '/dashboard'),
            ),
            _tile(
              Iconsax.shield_tick,
              "Verify Account",
              () => Navigator.pushNamed(context, '/workerverification'),
            ),

            // _tile(
            //   Iconsax.save_2,
            //   "Saved Jobs",
            //   () => Navigator.push(
            //     context,
            //     MaterialPageRoute(builder: (_) => const SavedJobsScreen()),
            //   ),
            // ),
            const SizedBox(height: 10),
            _sectionTitle("Jobs"),
            _tile(
              Iconsax.timer,
              "Pending Jobs",
              () => Navigator.pushNamed(context, '/posterpendingjobs'),
            ),
            _tile(
              Iconsax.briefcase,
              "Manage Jobs",
              () => Navigator.pushNamed(context, '/updatejobsscreen'),
            ),
            _tile(
              Iconsax.add_square,
              "Create Job Post",
              () => Navigator.pushNamed(context, '/postjobs'),
            ),
            _tile(
              Iconsax.close_square,
              "Declined Jobs",
              () => Navigator.pushNamed(context, '/rejectedjobs'),
            ),

            const SizedBox(height: 10),
            _sectionTitle("Finance & Support"),
            _tile(
              Iconsax.wallet_3,
              "Earnings Wallet",
              () => Navigator.pushNamed(context, '/userwallet'),
            ),
            _tile(
              Iconsax.message_question,
              "Help & Support",
              () => Navigator.pushNamed(context, '/helpsupport'),
            ),

            const SizedBox(height: 10),
            _sectionTitle("System"),
            _tile(
              Iconsax.repeat,
              "Switch to Employer",
              () => Navigator.pushNamed(context, '/nav'),
            ),
            // _tile(Iconsax.setting_2, "App Settings", () {
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (_) => WorkerSettingsScreen(
            //         toggleTheme: widget.toggleTheme,
            //         onLanguageChange: widget.onLanguageChange,
            //       ),
            //     ),
            //   );
            // }),

            const SizedBox(height: 20),
            _themeSwitcher(),
            const SizedBox(height: 20),

          ],
        ),
      ),
    );
  }

  // ------------------- UI Core Components -------------------

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6, top: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _tile(IconData icon, String title, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      elevation: isDark ? 0 : 1,
      child: ListTile(
        leading: Icon(icon, color: AppColors.button),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        trailing: Icon(
          Iconsax.arrow_right_3,
          color: isDark ? Colors.white70 : Colors.grey,
          size: 18,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _themeSwitcher() {
    return SwitchListTile(
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
    );
  }
}
