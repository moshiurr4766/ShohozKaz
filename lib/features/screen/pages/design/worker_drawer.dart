
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shohozkaz/core/constants.dart';
import 'package:shohozkaz/features/screen/pages/jobs/save%20job/job_save_screen.dart';

class WorkerDrawer extends StatelessWidget {
  final String userName;
  final String profileImage;
  final String userType;

  const WorkerDrawer({
    super.key,
    required this.userName,
    required this.profileImage,
    required this.userType,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(0),
        bottomRight: Radius.circular(0),
      ),
      child: Drawer(
        width: MediaQuery.of(context).size.width * 0.65,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              const SizedBox(height: 16),
              InkWell(
                onTap: () {},
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                      child: ClipOval(
                        child: profileImage.isNotEmpty
                            ? Image.network(
                                profileImage,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildFallbackAvatar(userName);
                                },
                              )
                            : _buildFallbackAvatar(userName),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            userType,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.button,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Theme(
                data: Theme.of(context).copyWith(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                ),
                child: Column(
                  children: [
                    _buildListTile(
                      context,
                      Iconsax.category,
                      'Overview',
                      () => Navigator.pushNamed(context, '/dashboard'),
                    ),
                    _buildListTile(
                      context,
                      Iconsax.shield_tick,
                      'Verify Account',
                      () => Navigator.pushNamed(context, '/workerverification'),
                    ),
                    _buildListTile(
                      context,
                      Iconsax.timer,
                      'Pending Jobs',
                      () => Navigator.pushNamed(context, '/posterpendingjobs'),
                    ),
                    _buildListTile(
                      context,
                      Iconsax.save_2,
                      'Saved Jobs',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SavedJobsScreen(),
                        ),
                      ),
                    ),
                    _buildListTile(
                      context,
                      Iconsax.briefcase,
                      'Manage Jobs',
                      () => Navigator.pushNamed(context, '/updatejobsscreen'),
                    ),
                    _buildListTile(
                      context,
                      Iconsax.add_square,
                      'Create Job Post',
                      () => Navigator.pushNamed(context, '/postjobs'),
                    ),
                    _buildListTile(
                      context,
                      Iconsax.close_square,
                      'Declined Jobs',
                      () => Navigator.pushNamed(context, '/rejectedjobs'),
                    ),
                    _buildListTile(
                      context,
                      Iconsax.wallet_3,
                      'Earnings Wallet',
                      () => Navigator.pushNamed(context, '/userwallet'),
                    ),
                    _buildListTile(
                      context,
                      Iconsax.message_question,
                      'Help & Support',
                      () => Navigator.pushNamed(context, '/helpsupport'),
                    ),
                    _buildListTile(
                      context,
                      Iconsax.repeat,
                      'Switch to Employer',
                      () => Navigator.pushNamed(context, '/nav'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Reusable ListTile builder
  ListTile _buildListTile(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
      ),
      onTap: onTap,
    );
  }

  /// Avatar fallback when no profile image
  Widget _buildFallbackAvatar(String userName) {
    return Container(
      color: Colors.grey[400],
      alignment: Alignment.center,
      child: Text(
        userName.isNotEmpty ? userName[0].toUpperCase() : "?",
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
