// import 'package:flutter/material.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:shohozkaz/core/constants.dart';

// import 'package:shohozkaz/features/screen/pages/jobs/save%20job/job_save_screen.dart';
// import 'package:shohozkaz/features/screen/pages/profile/user_info.dart';
// import 'package:shohozkaz/services/auth_service.dart';

// class CustomDrawer extends StatelessWidget {
//   final String userName;
//   final String profileImage;
//   final String userType;

//   const CustomDrawer({
//     super.key,
//     required this.userName,
//     required this.profileImage,
//     required this.userType,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: const BorderRadius.only(
//         topRight: Radius.circular(0),
//         bottomRight: Radius.circular(0),
//       ),
//       child: Drawer(
//         width: MediaQuery.of(context).size.width * 0.65,
//         child: SafeArea(
//           child: ListView(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             children: [
//               const SizedBox(height: 16),
//               InkWell(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const EditProfileScreen(),
//                     ),
//                   );
//                 },
//                 splashColor: Colors.transparent,
//                 highlightColor: Colors.transparent,
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Container(
//                       width: 60,
//                       height: 60,
//                       decoration: const BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: Colors.blue,
//                       ),
//                       child: ClipOval(
//                         child: profileImage.isNotEmpty
//                             ? Image.network(
//                                 profileImage,
//                                 fit: BoxFit.cover,
//                                 errorBuilder: (context, error, stackTrace) {
//                                   return Container(
//                                     color: Colors.grey[400],
//                                     alignment: Alignment.center,
//                                     child: Text(
//                                       userName.isNotEmpty
//                                           ? userName[0].toUpperCase()
//                                           : "?",
//                                       style: const TextStyle(
//                                         fontSize: 24,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               )
//                             : Container(
//                                 color: Colors.grey[400],
//                                 alignment: Alignment.center,
//                                 child: Text(
//                                   userName.isNotEmpty
//                                       ? userName[0].toUpperCase()
//                                       : "?",
//                                   style: const TextStyle(
//                                     fontSize: 24,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               ),
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             userName,
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           Text(
//                             userType,
//                             style: const TextStyle(
//                               fontSize: 12,
//                               color: AppColors.button,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const Icon(Iconsax.arrow_right_3),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 20),

//               // Menu List
//               Theme(
//                 data: Theme.of(context).copyWith(
//                   splashColor: Colors.transparent,
//                   highlightColor: Colors.transparent,
//                   hoverColor: Colors.transparent,
//                 ),
//                 child: Column(
//                   children: [
//                     ListTile(
//                       leading: const Icon(Iconsax.category),
//                       title: const Text('Dashboard'),
//                       onTap: () => Navigator.pushNamed(context, '/dashboard'),
//                     ),
//                     ListTile(
//                       leading: const Icon(Iconsax.home),
//                       title: const Text('Home'),
//                       onTap: () {},
//                     ),
//                     ListTile(
//                       leading: const Icon(Iconsax.briefcase),
//                       title: const Text('Find Jobs'),
//                       onTap: () => Navigator.pushNamed(context, '/findjobs'),
//                     ),
//                     ListTile(
//                       leading: const Icon(Iconsax.tick_square),
//                       title: const Text('My Jobs'),
//                       onTap: () => Navigator.pushNamed(context, '/myjobs'),
//                     ),
//                     ListTile(
//                       leading: const Icon(Iconsax.add_square),
//                       title: const Text('Post Jobs'),
//                       onTap: () => Navigator.pushNamed(context, '/postjobs'),
//                     ),
//                     ListTile(
//                       leading: const Icon(Iconsax.user),
//                       title: const Text('Update Jobs'),
//                       onTap: () {
//                         Navigator.pushNamed(context, '/updatejobsscreen');
//                       },
//                     ),
//                     ListTile(
//                       leading: const Icon(Iconsax.save_2),
//                       title: const Text('Saved Jobs'),
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => const SavedJobsScreen(),
//                           ),
//                         );
//                       },
//                     ),
//                     ListTile(
//                       leading: const Icon(Iconsax.wallet),
//                       title: const Text('Wallet'),
//                       onTap: () => Navigator.pushNamed(context, '/userwallet'),
//                     ),
//                     ListTile(
//                       leading: const Icon(Iconsax.support),
//                       title: const Text('Support'),
//                       onTap: () {
//                         Navigator.pushNamed(context, '/chathome');
//                       },
//                     ),
//                     ListTile(
//                       leading: const Icon(Iconsax.setting),
//                       title: const Text('Setting'),
//                       onTap: () => Navigator.pushNamed(context, '/settings'),
//                     ),
//                     const SizedBox(height: 5),

//                     ListTile(
//                       leading: const Icon(Iconsax.check1),
//                       title: const Text('User Pending'),
//                       onTap: () {
//                         Navigator.pushNamed(context, '/userpendingjobs');
//                       },
//                     ),
//                     const SizedBox(height: 5),

//                     ListTile(
//                       leading: const Icon(Iconsax.check1),
//                       title: const Text('Poster Pending'),
//                       onTap: () {
//                         Navigator.pushNamed(context, '/posterpendingjobs');
//                       },
//                     ),
//                     const SizedBox(height: 5),

//                     ListTile(
//                       leading: const Icon(Iconsax.activity),
//                       title: const Text('Rejected Jobs'),
//                       onTap: () {
//                         Navigator.pushNamed(context, '/rejectedjobs');
//                       },
//                     ),
//                     const SizedBox(height: 5),

//                     // ListTile(
//                     //   leading: const Icon(Iconsax.activity),
//                     //   title: const Text('Open User'),
//                     //   onTap: () {
//                     //     Navigator.pushNamed(context, '/completedusers');
//                     //   },
//                     // ),
//                     // const SizedBox(height: 5),

//                     // ListTile(
//                     //   leading: const Icon(Iconsax.activity),
//                     //   title: const Text('Open Poster'),
//                     //   onTap: () {
//                     //     Navigator.pushNamed(context, '/completedposter');
//                     //   },
//                     // ),
//                     // const SizedBox(height: 5),

//                     ListTile(
//                       leading: const Icon(Iconsax.logout, color: Colors.red),
//                       title: const Text('Logout'),
//                       onTap: () async {
//                         await authService.value.signOut();
//                         // ignore: use_build_context_synchronously
//                         Navigator.pushNamedAndRemoveUntil(
//                           // ignore: use_build_context_synchronously
//                           context,
//                           '/login',
//                           (route) => false,
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shohozkaz/core/constants.dart';
import 'package:shohozkaz/features/screen/pages/jobs/save%20job/job_save_screen.dart';
import 'package:shohozkaz/services/auth_service.dart';

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

              // Menu List
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
                      'Dashboard',
                      () => Navigator.pushNamed(context, '/dashboard'),
                    ),

                    // _buildListTile(
                    //   context,
                    //   Iconsax.search_normal,
                    //   'Find Workers',
                    //   () => Navigator.pushNamed(context, '/findjobs'),
                    // ),
                    _buildListTile(
                      context,
                      Iconsax.profile_tick,
                      'Profile Verification',
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
                      'Saved Workers',
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SavedJobsScreen(),
                          ),
                        );
                      },
                    ),
                    _buildListTile(
                      context,
                      Iconsax.close_square,
                      'Declined Jobs',
                      () => Navigator.pushNamed(context, '/rejectedjobs'),
                    ),
                    _buildListTile(
                      context,
                      Iconsax.transaction_minus,
                      'Transaction History',
                      () => Navigator.pushNamed(context, '/userwallet'),
                    ),

                    _buildListTile(
                      context,
                      Iconsax.message_question,
                      'Help & Support',
                      () => Navigator.pushNamed(context, '/chathome'),
                    ),

                    _buildListTile(
                      context,
                      Iconsax.repeat,
                      'Switch To Worker',
                      () => Navigator.pushNamed(context, '/workernavbar'),
                    ),
                    SizedBox(height: 120),
                    _buildListTile(context, Iconsax.logout, 'Logout', () async {
                      await authService.value.signOut();
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (route) => false,
                      );
                    }, color: Colors.red),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Reusable list tile builder
  ListTile _buildListTile(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? color,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: color ?? Theme.of(context).colorScheme.primary,
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: color ?? Theme.of(context).colorScheme.onSurface,
        ),
      ),
      onTap: onTap,
    );
  }

  /// Fallback avatar when no profile image
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
