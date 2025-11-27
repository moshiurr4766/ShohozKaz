import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shohozkaz/core/constants.dart';
import 'package:shohozkaz/features/screen/pages/profile/user_info.dart';

class AccountSettingsScreen extends StatefulWidget {
  final Function(ThemeMode) toggleTheme;

  const AccountSettingsScreen({super.key, required this.toggleTheme});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen>
    with SingleTickerProviderStateMixin {
  bool isDark = false;

  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    userStream();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> userStream() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('userInfo')
        .doc(uid)
        .snapshots();
  }

  // Smooth Theme Switching
  void _onThemeChanged(bool value) {
    setState(() => isDark = value);
    Future.delayed(const Duration(milliseconds: 120), () {
      widget.toggleTheme(value ? ThemeMode.dark : ThemeMode.light);
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    isDark = brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F0F0F)
          : const Color(0xFFF8F8F8),

      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Account Settings",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? Colors.black : Colors.white,
        
      ),

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: ListView(
          padding: const EdgeInsets.only(bottom: 20),
          children: [
            const SizedBox(height: 16),

            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: userStream(),
              builder: (context, snap) {
                if (!snap.hasData || !snap.data!.exists) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final userData = snap.data!.data()!;

                return _buildProfileHeader(userData);
              },
            ),

            const SizedBox(height: 20),

            _sectionTitle("Appearance"),

            _smoothTile(
              Iconsax.moon,
              "Dark Mode",
              trailing: Switch(
                value: isDark,
                activeColor: AppColors.button,
                onChanged: _onThemeChanged,
              ),
            ),

            _divider(),

            _sectionTitle("Account"),

            _smoothTile(
              Iconsax.user,
              "Edit Profile",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                );
              },
            ),

            _smoothTile(
              Iconsax.repeat,
              "Switch To Worker",
              onTap: () => Navigator.pushNamed(context, '/workernavbar'),
            ),

            _smoothTile(
              Iconsax.password_check,
              "Change Password",
              onTap: () => Navigator.pushNamed(context, '/changepassword'),
            ),

            _smoothTile(
              Iconsax.trash,
              "Delete Account",
              color: Colors.redAccent,
              onTap: _deleteAccountDialog,
            ),

            // _divider(),

            // _sectionTitle("Settings"),

            // _smoothTile(
            //   Iconsax.notification,
            //   "Notifications",
            //   showChevron: true,
            // ),

            // _smoothTile(Iconsax.shield_tick, "Permissions"),
            const SizedBox(height: 30),

            // LOGOUT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                icon: const Icon(Iconsax.logout, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                label: const Text(
                  "Logout",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                onPressed: _logout,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // PROFILE HEADER


  Widget _buildProfileHeader(Map<String, dynamic> userData) {
    final dark = isDark;
    final name = userData['name'] ?? "User";
    final email = userData['email'] ?? "";
    final imageUrl = userData['profileImage'];
    final status = userData['status'] ?? "active";
    final ratingValue = userData['avgRating'] ?? 0;
    final ratingCount = userData['ratingCount'] ?? 0;

    final rd = double.tryParse(ratingValue.toString()) ?? 0.0;
    final rating = rd.toStringAsFixed(1);

    final width = MediaQuery.of(context).size.width;
    final horizontalPadding = width * 0.04;
    final avatarRadius = width * 0.08;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
      padding: EdgeInsets.all(horizontalPadding),
      decoration: BoxDecoration(
        color: AppColors.button,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: avatarRadius,
            backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
            backgroundColor: dark
                ? Colors.grey.shade700
                : Colors.white.withOpacity(0.3),
            child: imageUrl == null
                ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : "?",
                    style: TextStyle(
                      fontSize: width * 0.06,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          SizedBox(width: width * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: width * 0.045,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  email,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: width * 0.032,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.025,
                    vertical: width * 0.01,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.yellow),
                      const SizedBox(width: 3),
                      Text(
                        "$rating ($ratingCount)",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.03,
              vertical: width * 0.015,
            ),
            decoration: BoxDecoration(
              color: status == "active"
                  ? Colors.green
                  : Colors.redAccent,
              borderRadius: BorderRadius.circular(20),
              
            ),
            child: Text(
              status.toUpperCase(),
              style: TextStyle(
                color: const Color.fromARGB(255, 255, 255, 255),
                fontWeight: FontWeight.bold,
                fontSize: width * 0.028,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // SMOOTH TILE
  Widget _smoothTile(
    IconData icon,
    String title, {
    bool showChevron = false,
    Color? color,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    final dark = isDark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: dark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(icon, color: color ?? AppColors.button, size: 24),
        title: Text(
          title,
          style: TextStyle(
            color: dark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing:
            trailing ??
            (showChevron
                ? Icon(
                    Iconsax.arrow_right_3,
                    color: dark ? Colors.white70 : Colors.grey,
                  )
                : null),
        onTap: onTap,
      ),
    );
  }

  // DELETE ACCOUNT
  Future<void> _deleteAccountDialog() async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Account?"),
        content: const Text("This action is permanent and cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.currentUser?.delete();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    }
  }

  // LOGOUT
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  // SECTION TITLE
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white70 : Colors.grey.shade700,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      height: 10,
      color: isDark ? Colors.white12 : Colors.black12,
    );
  }
}
