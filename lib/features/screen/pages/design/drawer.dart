import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

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
    return ClipRRect(
      
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(60),
        bottomRight: Radius.circular(60),
      ),
      child: Drawer(
        child: SafeArea( 
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              const SizedBox(height: 16),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  // Navigator.pushNamed(context, '/profile');
                },
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
                        child: Image.asset(profileImage, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userName, style: const TextStyle(fontSize: 18)),
                          Text(userType, style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                    const Icon(Iconsax.arrow_right_3),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Menu List with ripple effects disabled
              Theme(
                data: Theme.of(context).copyWith(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Iconsax.category),
                      title: const Text('Dashboard'),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: const Icon(Iconsax.home),
                      title: const Text('Home'),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: const Icon(Iconsax.briefcase),
                      title: const Text('Find Jobs'),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: const Icon(Iconsax.tick_square),
                      title: const Text('My Jobs'),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: const Icon(Iconsax.add_square),
                      title: const Text('Post Jobs'),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: const Icon(Iconsax.save_2),
                      title: const Text('Saved Jobs'),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: const Icon(Iconsax.wallet),
                      title: const Text('Wallet'),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: const Icon(Iconsax.support),
                      title: const Text('Support'),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: const Icon(Iconsax.setting),
                      title: const Text('Setting'),
                      onTap: () {},
                    ),
                    const SizedBox(height: 20), 
                    ListTile(
                      leading: const Icon(Iconsax.logout, color: Colors.red),
                      title: const Text('Logout'),
                      onTap: () {
                        Navigator.pop(context);
                      },
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
}
