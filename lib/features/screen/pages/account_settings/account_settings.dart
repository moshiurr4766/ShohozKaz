import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shohozkaz/features/screen/pages/profile/user_info.dart';
import 'package:shohozkaz/l10n/app_localizations.dart';

class AccountSettingsScreen extends StatefulWidget {
  final Function(ThemeMode) toggleTheme;
  final Function(Locale) onLanguageChange;

  const AccountSettingsScreen({
    super.key,
    required this.toggleTheme,
    required this.onLanguageChange,
  });

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  late bool isDark;
  bool _isLanguageExpanded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isDark = Theme.of(context).brightness == Brightness.dark;
  }

  void _onThemeChanged(bool value) {
    setState(() => isDark = value);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.toggleTheme(value ? ThemeMode.dark : ThemeMode.light);
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          loc.accountSettings,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: const BackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          const SizedBox(height: 16),
          _buildProfileHeader(context),
          const SizedBox(height: 16),
          _buildDivider(),

          _buildDarkModeSwitch(context, color, loc),
          _buildDivider(),

          _buildTile(Iconsax.notification, loc.notifications, showChevron: true),
          _buildDivider(),

          _buildSectionTitle(loc.account),
          _buildTile(Iconsax.user, loc.profile,onTap: () {
                              Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
          },),
          _buildTile(Iconsax.briefcase, loc.workerAccount,onTap: (){
            Navigator.pushNamed(context, '/workernavbar');
          }),
          _buildTile(Iconsax.card, loc.digitalPayment),
          _buildTile(Iconsax.bookmark, loc.savedAddress),
          _buildDivider(),

          _buildSectionTitle(loc.offers),
          _buildTile(Iconsax.discount_shape, loc.promos),
          _buildTile(Iconsax.gift, loc.referDiscounts),
          _buildDivider(),

          _buildSectionTitle(loc.settings),
          _buildTile(
            Iconsax.global,
            loc.language,
            onTap: () {
              setState(() => _isLanguageExpanded = !_isLanguageExpanded);
            },
          ),
          if (_isLanguageExpanded) _buildLanguageOptions(),
          _buildTile(Iconsax.shield_tick, loc.permissions),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white, size: 36),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'moshiur',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 2),
                const Text('01307266218', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.star, size: 14, color: Colors.orange),
                      SizedBox(width: 6),
                      Text(
                        'N/A',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.chevron_right, size: 16, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDarkModeSwitch(
    BuildContext context,
    ColorScheme color,
    AppLocalizations loc,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: color.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(Icons.wb_sunny_outlined, color: Colors.grey.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Text(loc.darkMode, style: const TextStyle(fontSize: 15)),
            ),
            Switch(
              value: isDark,
              inactiveThumbColor: Colors.grey,
              trackOutlineColor: WidgetStateProperty.all(Colors.grey),
              onChanged: _onThemeChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOptions() {
    final selectedLang = Localizations.localeOf(context).languageCode;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 40.0, right: 16.0, bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton(
            onPressed: () {
              setState(() => _isLanguageExpanded = false);
              widget.onLanguageChange(const Locale('en'));
            },
            child: Text(
              'English',
              style: TextStyle(
                fontSize: 15,
                color: selectedLang == 'en'
                    ? colorScheme.primary
                    : colorScheme.onSurface,
                fontWeight: selectedLang == 'en'
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() => _isLanguageExpanded = false);
              widget.onLanguageChange(const Locale('bn'));
            },
            child: Text(
              'বাংলা',
              style: TextStyle(
                fontSize: 15,
                color: selectedLang == 'bn'
                    ? colorScheme.primary
                    : colorScheme.onSurface,
                fontWeight: selectedLang == 'bn'
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTile(
    IconData icon,
    String title, {
    bool showChevron = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      horizontalTitleGap: 12,
      dense: true,
      leading: Icon(icon, size: 22, color: Colors.grey.shade700),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      trailing: showChevron
          ? const Icon(Icons.chevron_right, color: Colors.grey)
          : null,
      onTap: onTap ?? () {},
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      height: 8,
      color: Colors.grey.withOpacity(0.08),
    );
  }
}





