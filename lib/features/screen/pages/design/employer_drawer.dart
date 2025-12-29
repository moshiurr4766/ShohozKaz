


import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shohozkaz/core/constants.dart';
import 'package:shohozkaz/features/screen/pages/jobs/save job/job_save_screen.dart';

class CustomDrawer extends StatelessWidget {
  final String userName;
  final String profileImage;
  final String userType;

  const CustomDrawer({
    super.key,
    required this.userName,
    required this.profileImage,
    required this.userType,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.70,
      backgroundColor: isDark ? const Color(0xFF111111) : Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [

                  _sectionTitle("Jobs", isDark),
                  _drawerTile(
                    context,
                    title: "Pending Request",
                    icon: Iconsax.timer,
                    onTap: () => Navigator.pushNamed(context, '/userpendingjobs'),
                  ),
                  _drawerTile(
                    context,
                    title: "Saved Services",
                    icon: Iconsax.save_2,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SavedJobsScreen(),
                      ),
                    ),
                  ),
                  _drawerTile(
                    context,
                    title: "Declined Services",
                    icon: Iconsax.close_square,
                    onTap: () => Navigator.pushNamed(context, '/rejectedjobs'),
                  ),

                  const SizedBox(height: 10),

                  _sectionTitle("Finance", isDark),
                  _drawerTile(
                    context,
                    title: "Transaction History",
                    icon: Iconsax.transaction_minus,
                    onTap: () => Navigator.pushNamed(context, '/userwallet'),
                  ),

                  const SizedBox(height: 10),

                  _sectionTitle("Support", isDark),
                  _drawerTile(
                    context,
                    title: "Help & Support",
                    icon: Iconsax.message_question,
                    onTap: () => Navigator.pushNamed(context, '/helpsupport'),
                  ),

                  const SizedBox(height: 30),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  // HEADER UI

  Widget _buildHeader(BuildContext context, bool isDark) {
  final safeName = userName.trim();
  final hasImage = profileImage.trim().isNotEmpty && profileImage != "null";

  return Container(
    margin: const EdgeInsets.all(14),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF1D1D1D) : AppColors.button,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        // PROFILE IMAGE WITH FALLBACK
        ClipOval(
          child: SizedBox(
            width: 60,
            height: 60,
            child: hasImage
                ? Image.network(
                    profileImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildFallbackAvatar(safeName),
                  )
                : _buildFallbackAvatar(safeName),
          ),
        ),

        const SizedBox(width: 14),

        // NAME + ROLE
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                safeName.isNotEmpty ? safeName : "User",
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              const Text(
                "Employee",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}


  // Drawer Tile
  Widget _drawerTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(icon,
            size: 22, color: color ?? AppColors.button),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        // trailing: Icon(
        //   Iconsax.arrow_right_3,
        //   color: isDark ? Colors.white54 : Colors.black45,
        //   size: 18,
        // ),
        onTap: onTap,
      ),
    );
  }

  // Section Title
  Widget _sectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white70 : Colors.black54,
        ),
      ),
    );
  }


 // Avatar fallback
  // ---------------------------------------------------------------------------
  Widget _buildFallbackAvatar(String userName) {
    return Container(
      color: Colors.grey.shade400,
      alignment: Alignment.center,
      child: Text(
        userName.isNotEmpty ? userName[0].toUpperCase() : "?",
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

}
