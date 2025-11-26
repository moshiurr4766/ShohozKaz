// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:shohozkaz/core/constants.dart';

// class ProfileMenuItem {
//   final IconData icon;
//   final String title;
//   final VoidCallback onTap;

//   ProfileMenuItem({
//     required this.icon,
//     required this.title,
//     required this.onTap,
//   });
// }

// class WorkerHomeDashboard extends StatefulWidget {
//   const WorkerHomeDashboard({super.key});

//   @override
//   State<WorkerHomeDashboard> createState() => _WorkerHomeDashboardState();
// }

// class _WorkerHomeDashboardState extends State<WorkerHomeDashboard> {
//   // Use a clear name to avoid any “lookup failed” confusion.
//   final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

//   // ----------------- small helpers -----------------
//   String s(dynamic v, [String fallback = ""]) =>
//       v == null ? fallback : v.toString();

//   num n(dynamic v, [num fallback = 0]) =>
//       v is num ? v : (num.tryParse(v.toString()) ?? fallback);

//   // ----------------- FIRESTORE HELPERS -----------------

//   /// Dashboard stats: how many pending / active / done jobs for this worker
//   Future<Map<String, int>> _loadStats(String uid) async {
//     final pendingSnap = await FirebaseFirestore.instance
//         .collection('pendingJobs')
//         .where('applicantId', isEqualTo: uid)
//         .get();

//     final activeSnap = await FirebaseFirestore.instance
//         .collection('openJobs')
//         .where('applicantId', isEqualTo: uid)
//         .get();

//     final doneSnap = await FirebaseFirestore.instance
//         .collection('completedJobs')
//         .where('applicantId', isEqualTo: uid)
//         .get();

//     return {
//       'pending': pendingSnap.size,
//       'active': activeSnap.size,
//       'done': doneSnap.size,
//     };
//   }

//   /// Active jobs for this worker (openJobs collection)
//   Stream<QuerySnapshot<Map<String, dynamic>>> _activeJobs(String uid) {
//     return FirebaseFirestore.instance
//         .collection('openJobs')
//         .where('applicantId', isEqualTo: uid)
//         .snapshots();
//   }

//   /// AI-based recommended jobs: open jobs scored using worker + job attributes
//   Future<List<Map<String, dynamic>>> _getAIRecommendedJobs(String uid) async {
//     final userSnap = await FirebaseFirestore.instance
//         .collection('userInfo')
//         .doc(uid)
//         .get();
//     if (!userSnap.exists) return [];

//     final user = userSnap.data()!;
//     final workerSkill = s(user['skill'] ?? user['mainSkill']);
//     final workerLocation = s(user['location']);
//     final workerExperience = s(user['experience']); // if you store it

//     // Fetch open jobs (limit to avoid huge lists)
//     final jobSnap = await FirebaseFirestore.instance
//         .collection('jobs')
//         .where('status', isEqualTo: 'open')
//         .limit(50)
//         .get();

//     List<Map<String, dynamic>> jobs = [];

//     for (var doc in jobSnap.docs) {
//       final data = doc.data();

//       final score = _computeAIScore(
//         workerSkill: workerSkill,
//         workerLocation: workerLocation,
//         workerExperience: workerExperience,
//         job: data,
//       );

//       // If score is very low, skip (not a good match)
//       if (score <= 0.5) continue;

//       data['aiScore'] = score;
//       jobs.add(data);
//     }

//     // If no good matches or worker skill is empty, fallback to most recent jobs
//     if (jobs.isEmpty) {
//       final fallbackSnap = await FirebaseFirestore.instance
//           .collection('jobs')
//           .where('status', isEqualTo: 'open')
//           .orderBy('postedAt', descending: true)
//           .limit(10)
//           .get();

//       jobs = fallbackSnap.docs.map((d) => d.data()).toList();
//       for (var j in jobs) {
//         j['aiScore'] = 1.0; // neutral score
//       }
//     }

//     // Sort by AI score (high → low)
//     jobs.sort((a, b) => b['aiScore'].compareTo(a['aiScore']));
//     return jobs;
//   }

//   /// AI scoring: simple heuristic using skill, location, recency, etc.
//   double _computeAIScore({
//     required String workerSkill,
//     required String workerLocation,
//     required String workerExperience,
//     required Map<String, dynamic> job,
//   }) {
//     double score = 0;

//     final jobSkill = s(job['skill']).toLowerCase();
//     final jobLocation = s(job['location']).toLowerCase();
//     final jobExperience = s(job['experience']);
//     final jobType = s(job['jobType']).toLowerCase();

//     // --- skill match (weight ~ 4)
//     if (workerSkill.isNotEmpty && jobSkill == workerSkill.toLowerCase()) {
//       score += 4;
//     } else if (workerSkill.isNotEmpty &&
//         jobSkill.contains(workerSkill.toLowerCase())) {
//       score += 2.5;
//     }

//     // --- experience match (weight ~ 2)
//     if (workerExperience.isNotEmpty && jobExperience == workerExperience) {
//       score += 2;
//     }

//     // --- location (weight ~ 2)
//     if (workerLocation.isNotEmpty &&
//         jobLocation == workerLocation.toLowerCase()) {
//       score += 2;
//     } else if (workerLocation.isNotEmpty &&
//         jobLocation.contains(workerLocation.toLowerCase())) {
//       score += 1;
//     }

//     // --- recency (weight ~ 1)
//     try {
//       final ts = job['postedAt'];
//       if (ts is Timestamp) {
//         final days = DateTime.now().difference(ts.toDate()).inDays;
//         if (days <= 1) {
//           score += 1;
//         } else if (days <= 3) {
//           score += 0.7;
//         } else if (days <= 7) {
//           score += 0.4;
//         }
//       }
//     } catch (_) {
//       // ignore parsing issues
//     }

//     // --- job type bonus (optional; tweak as needed)
//     if (jobType.contains('part')) score += 0.2;
//     if (jobType.contains('full')) score += 0.2;

//     return score;
//   }

//   // ----------------- UI BUILD -----------------

//   @override
//   Widget build(BuildContext context) {
//     final uid = _firebaseAuth.currentUser?.uid;
//     if (uid == null) {
//       return const Scaffold(body: Center(child: Text("User not logged in")));
//     }

//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final backgroundColor = isDark
//         ? const Color(0xFF000000)
//         : const Color(0xFFF7F7F7);

//     return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
//       stream: FirebaseFirestore.instance
//           .collection('userInfo')
//           .doc(uid)
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData || !snapshot.data!.exists) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }

//         final user = snapshot.data!.data()!;
//         final name = s(user['name'], 'Worker');
//         final skill = s(user['skill'] ?? user['mainSkill'], 'Skill not set');
//         final profileImg = s(user['profileImage']);
//         final location = s(user['location']);
//         final avgRating = n(user['avgRating'], 0).toDouble();
//         final ratingCount = n(user['ratingCount'], 0).toInt();

//         return Scaffold(
//           backgroundColor: backgroundColor,
//           body: SafeArea(
//             child: RefreshIndicator(
//               onRefresh: () async => setState(() {}),
//               child: SingleChildScrollView(
//                 physics: const AlwaysScrollableScrollPhysics(),
//                 padding: const EdgeInsets.all(14),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _headerCard(
//                       context,
//                       name: name,
//                       skill: skill,
//                       profileImg: profileImg,
//                       location: location,
//                       avgRating: avgRating,
//                       ratingCount: ratingCount,
//                     ),
//                     const SizedBox(height: 16),

//                     // Stats row
//                     FutureBuilder<Map<String, int>>(
//                       future: _loadStats(uid),
//                       builder: (context, snap) {
//                         if (!snap.hasData) {
//                           return const Padding(
//                             padding: EdgeInsets.symmetric(vertical: 16),
//                             child: Center(child: CircularProgressIndicator()),
//                           );
//                         }
//                         return _statsRow(context, snap.data!);
//                       },
//                     ),

//                     const SizedBox(height: 20),

//                     // Active Jobs
//                     _sectionTitle(context, "Active Jobs"),
//                     const SizedBox(height: 6),
//                     StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//                       stream: _activeJobs(uid),
//                       builder: (context, snap) {
//                         if (!snap.hasData) {
//                           return const Padding(
//                             padding: EdgeInsets.symmetric(vertical: 12),
//                             child: Center(child: CircularProgressIndicator()),
//                           );
//                         }
//                         final docs = snap.data!.docs;
//                         if (docs.isEmpty) {
//                           return Text(
//                             "You have no active jobs right now.",
//                             style: _subtitleStyle(isDark),
//                           );
//                         }
//                         return Column(
//                           children: docs
//                               .map(
//                                 (d) => _jobTile(
//                                   context,
//                                   d.data(),
//                                   isDark,
//                                   showStatus: true,
//                                 ),
//                               )
//                               .toList(),
//                         );
//                       },
//                     ),

//                     const SizedBox(height: 20),

//                     // AI Recommended jobs
//                     _sectionTitle(context, "Recommended for you"),
//                     const SizedBox(height: 6),
//                     FutureBuilder<List<Map<String, dynamic>>>(
//                       future: _getAIRecommendedJobs(uid),
//                       builder: (context, snap) {
//                         if (snap.connectionState == ConnectionState.waiting) {
//                           return const Padding(
//                             padding: EdgeInsets.symmetric(vertical: 16),
//                             child: Center(
//                               child: CircularProgressIndicator(
//                                 color: AppColors.button,
//                               ),
//                             ),
//                           );
//                         }

//                         if (!snap.hasData || snap.data!.isEmpty) {
//                           return Text(
//                             "No recommended jobs right now.",
//                             style: _subtitleStyle(isDark),
//                           );
//                         }

//                         final jobs = snap.data!;
//                         return Column(
//                           children: jobs
//                               .map(
//                                 (j) => _jobTile(
//                                   context,
//                                   j,
//                                   isDark,
//                                   showStatus: false,
//                                   showScore: true,
//                                 ),
//                               )
//                               .toList(),
//                         );
//                       },
//                     ),

// const SizedBox(height: 20),

// // Tips
// _sectionTitle(context, "Tips to earn more"),
// const SizedBox(height: 8),
// _tipsCard(context),

// const SizedBox(height: 22),

//                     const SizedBox(height: 30),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _headerCard(
//     BuildContext context, {
//     required String name,
//     required String skill,
//     required String profileImg,
//     required String location,
//     required double avgRating,
//     required int ratingCount,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColors.button,
//         borderRadius: BorderRadius.circular(18),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // PROFILE IMAGE
//           CircleAvatar(
//             radius: 32,
//             backgroundImage: profileImg.isNotEmpty
//                 ? NetworkImage(profileImg)
//                 : null,
//             child: profileImg.isEmpty
//                 ? Text(
//                     name.isNotEmpty ? name[0].toUpperCase() : "W",
//                     style: const TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   )
//                 : null,
//           ),

//           const SizedBox(width: 14),

//           // FIX: EXPANDED PREVENTS OVERFLOW
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Hi, $name 👋",
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),

//                 const SizedBox(height: 4),

//                 Text(
//                   skill,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     color: Colors.white.withOpacity(0.95),
//                     fontSize: 13,
//                   ),
//                 ),

//                 if (location.isNotEmpty) ...[
//                   const SizedBox(height: 2),
//                   Text(
//                     location,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       color: Colors.white.withOpacity(0.9),
//                       fontSize: 11,
//                     ),
//                   ),
//                 ],

//                 const SizedBox(height: 6),

//                 Row(
//                   children: [
//                     const Icon(Icons.star, color: Colors.yellow, size: 18),
//                     const SizedBox(width: 4),
//                     Text(
//                       avgRating.toStringAsFixed(1),
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 13,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     Text(
//                       "  ($ratingCount reviews)",
//                       style: TextStyle(
//                         color: Colors.white.withOpacity(0.9),
//                         fontSize: 11,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   TextStyle _subtitleStyle(bool isDark) => TextStyle(
//     fontSize: 13,
//     color: isDark ? Colors.grey[400] : Colors.grey[700],
//   );

//   Widget _statsRow(BuildContext context, Map<String, int> stats) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     Widget box(String label, int value, IconData icon, Color color) {
//       return Expanded(
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//           margin: const EdgeInsets.symmetric(horizontal: 4),
//           decoration: BoxDecoration(
//             color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//             borderRadius: BorderRadius.circular(14),
//           ),
//           child: Column(
//             children: [
//               Icon(icon, size: 20, color: color),
//               const SizedBox(height: 6),
//               Text(
//                 value.toString(),
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w700,
//                   color: isDark ? Colors.white : Colors.black87,
//                 ),
//               ),
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 11,
//                   color: isDark ? Colors.grey[300] : Colors.grey[700],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return Column(
//       children: [
//         Row(
//           children: [
//             box("Post Jobs", stats[""] ?? 0, Iconsax.timer, Colors.orange),
//             box("Active", stats['active'] ?? 0, Iconsax.play, Colors.blue),
//           ],
//         ),
//         SizedBox(height: 12),
//         Row(
//           children: [
//             box("Pending", stats['pending'] ?? 0, Iconsax.timer, Colors.orange),
//             box("Completed", stats['done'] ?? 0, Iconsax.verify, Colors.green),
//           ],
//         ),
//       ],
//     );
//   }

// Widget _sectionTitle(BuildContext context, String title) {
//   final isDark = Theme.of(context).brightness == Brightness.dark;
//   return Text(
//     title,
//     style: TextStyle(
//       fontSize: 16,
//       fontWeight: FontWeight.w700,
//       color: isDark ? Colors.white : Colors.black87,
//     ),
//   );
// }

//   Widget _jobTile(
//     BuildContext context,
//     Map<String, dynamic> job,
//     bool isDark, {
//     bool showStatus = false,
//     bool showScore = false,
//   }) {
//     final title = s(job['title'] ?? job['jobTitle'], 'Untitled job');
//     final location = s(job['location'], 'Unknown location');
//     final salary = s(job['salary'], 'N/A');
//     final imageUrl = s(job['imageUrl']);
//     final status = s(job['status']);
//     final score = n(job['aiScore'], 0).toDouble();

//     return Container(
//       margin: const EdgeInsets.only(bottom: 10),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(10),
//             child: Container(
//               width: 55,
//               height: 55,
//               color: Colors.grey[300],
//               child: imageUrl.isNotEmpty
//                   ? Image.network(imageUrl, fit: BoxFit.cover)
//                   : const Icon(Iconsax.briefcase, size: 26),
//             ),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: isDark ? Colors.white : Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   location,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: isDark ? Colors.grey[400] : Colors.grey[700],
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Row(
//                   children: [
//                     Text(
//                       "৳ $salary",
//                       style: const TextStyle(
//                         fontSize: 13,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.green,
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     if (showStatus && status.isNotEmpty)
//                       _chip(status.toUpperCase(), Colors.blue),
//                     if (showScore && score > 0)
//                       Padding(
//                         padding: const EdgeInsets.only(left: 6),
//                         child: _chip(
//                           "Match ${score.toStringAsFixed(1)}",
//                           Colors.orange,
//                         ),
//                       ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _chip(String text, Color color) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(999),
//         color: color.withOpacity(0.12),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(
//           fontSize: 10,
//           fontWeight: FontWeight.w600,
//           color: color,
//         ),
//       ),
//     );
//   }

// Widget _tipsCard(BuildContext context) {
//   final isDark = Theme.of(context).brightness == Brightness.dark;

//   return Container(
//     padding: const EdgeInsets.all(14),
//     decoration: BoxDecoration(
//       color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//       borderRadius: BorderRadius.circular(14),
//     ),
//     child: Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             color: AppColors.button.withOpacity(0.18),
//             borderRadius: BorderRadius.circular(999),
//           ),
//           child: const Icon(Iconsax.trend_up, color: AppColors.button),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Text(
//             "Respond quickly to new job offers, keep your profile updated, and maintain a high rating to get more work.",
//             style: TextStyle(
//               fontSize: 12,
//               height: 1.4,
//               color: isDark ? Colors.grey[200] : Colors.grey[800],
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }
// }

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:rxdart/rxdart.dart';

// import 'package:shohozkaz/core/constants.dart';

// class WorkerHomeDashboard extends StatefulWidget {
//   const WorkerHomeDashboard({super.key});

//   @override
//   State<WorkerHomeDashboard> createState() => _WorkerHomeDashboardState();
// }

// class _WorkerHomeDashboardState extends State<WorkerHomeDashboard> {
//   final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
//   int completedJobsCount = 0;

//   // Helpers
//   String s(dynamic v, [String fallback = ""]) {
//     if (v == null) return fallback;
//     if (v is String) return v;
//     return v.toString();
//   }

//   num n(dynamic v, [num fallback = 0]) {
//     if (v == null) return fallback;
//     if (v is num) return v;
//     return num.tryParse(v.toString()) ?? fallback;
//   }

//   Stream<Map<String, int>> statsStream(String uid) {
//     final pending = FirebaseFirestore.instance
//         .collection('pendingJobs')
//         .where('posterId', isEqualTo: uid)
//         .where('status', whereIn: ['pending', 'confirmed'])
//         .snapshots();

//     final active = FirebaseFirestore.instance
//         .collection('openJobs')
//         .where('posterId', isEqualTo: uid)
//         .where('status', whereIn: ['open', 'in_progress', 'accepted'])
//         .snapshots();

//     final requestToPay = FirebaseFirestore.instance
//         .collection('openJobs')
//         .where('posterId', isEqualTo: uid)
//         .where('status', isEqualTo: 'waiting_payment')
//         .snapshots();

//     final completed = FirebaseFirestore.instance
//         .collection('completedJobs')
//         .where('posterId', isEqualTo: uid)
//         .where('status', isEqualTo: 'completed')
//         .snapshots();

//     final totalpost = FirebaseFirestore.instance
//         .collection('jobs')
//         .where('employerId', isEqualTo: uid)
//         .snapshots();

//     final reject = FirebaseFirestore.instance
//         .collection('rejectJobs')
//         .where('posterId', isEqualTo: uid)
//         .where('status', isEqualTo: 'rejected')
//         .snapshots();

//     return Rx.combineLatest6(
//       pending,
//       active,
//       completed,
//       totalpost,
//       reject,
//       requestToPay,
//       (p, a, c, d, e, f) => {
//         'pending': p.size,
//         'active': a.size,
//         'done': c.size,
//         'totaljobs': d.size,
//         'reject': e.size,
//         'requestToPay': f.size,
//       },
//     );
//   }

//   Stream<QuerySnapshot<Map<String, dynamic>>> activeJobs(String uid) {
//     return FirebaseFirestore.instance
//         .collection('openJobs')
//         .where('applicantId', isEqualTo: uid)
//         .where(
//           'status',
//           whereIn: [
//             'open',
//             'in_progress',
//             'accepted',
//             'waiting_payment',
//             'completed',
//           ],
//         )
//         .orderBy('requestedAt', descending: true)
//         .snapshots();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final uid = _firebaseAuth.currentUser?.uid;

//     if (uid == null) {
//       return const Scaffold(body: Center(child: Text("User not logged in")));
//     }

//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final background = isDark
//         ? const Color(0xFF000000)
//         : const Color(0xFFF7F7F7);

//     return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
//       stream: FirebaseFirestore.instance
//           .collection('userInfo')
//           .doc(uid)
//           .snapshots(),
//       builder: (context, userSnap) {
//         if (userSnap.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }

//         if (!userSnap.hasData || !userSnap.data!.exists) {
//           return const Scaffold(
//             body: Center(child: Text("User profile not found")),
//           );
//         }

//         final user = userSnap.data!.data() ?? {};
//         final status = s(user['status']);

//         // If banned/blocked
//         if (status == "banned" || status == "blocked") {
//           return const Scaffold(
//             body: Center(
//               child: Text(
//                 "Your account is banned.\nPlease contact support.",
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           );
//         }

//         final name = s(user['name'], "Worker");
//         final profileImg = s(user['profileImage']);
//         final location = s(user['location']);
//         final avgRating = n(user['avgRating']).toDouble();
//         final ratingCount = n(user['ratingCount']).toInt();

//         // Determine worker label based on total completed jobs.

//         final totalCompleted = (completedJobsCount > 0)
//             ? completedJobsCount
//             : n(user['completedJobs']).toInt();

//         final String workerLabel;
//         if (totalCompleted <= 0) {
//           workerLabel = "New Worker";
//         } else if (totalCompleted <= 5) {
//           workerLabel = "Beginner";
//         } else if (totalCompleted <= 20) {
//           workerLabel = "Intermediate";
//         } else if (totalCompleted <= 50) {
//           workerLabel = "Experienced";
//         } else if (totalCompleted <= 99) {
//           workerLabel = "Expert";
//         } else {
//           workerLabel = "Master Worker";
//         }

//         // Optionally: expose as a variable for the rest of the widget build
//         // e.g. you can display workerLabel somewhere in the UI.

//         return Scaffold(
//           backgroundColor: background,
//           body: SafeArea(
//             child: RefreshIndicator(
//               onRefresh: () async {
//                 if (mounted) setState(() {});
//               },
//               child: SingleChildScrollView(
//                 physics: const AlwaysScrollableScrollPhysics(),
//                 padding: const EdgeInsets.all(14),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Header
//                     _headerCard(
//                       name: name,
//                       workerLevel: workerLabel,
//                       profileImg: profileImg,
//                       location: location,
//                       avgRating: avgRating,
//                       ratingCount: ratingCount,
//                     ),

//                     const SizedBox(height: 20),

//                     _sectionTitles(context, "Worker Dashboard"),
//                     const SizedBox(height: 20),

//                     StreamBuilder<Map<String, int>>(
//                       stream: statsStream(uid),
//                       builder: (context, snap) {
//                         if (snap.connectionState == ConnectionState.waiting) {
//                           return const Center(
//                             child: CircularProgressIndicator(),
//                           );
//                         }
//                         return _statsRow(snap.data!);
//                       },
//                     ),

//                     const SizedBox(height: 20),

//                     // Tips
//                     _sectionTitles(context, "Tips to earn more"),

//                     const SizedBox(height: 8),
//                     _tipsCard(context),

//                     const SizedBox(height: 22),

//                     const SizedBox(height: 30),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // UI PARTS

//   Widget _headerCard({
//     required String name,
//     required String workerLevel,
//     required String profileImg,
//     required String location,
//     required double avgRating,
//     required int ratingCount,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: AppColors.button,
//         borderRadius: BorderRadius.circular(18),
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 32,
//             backgroundImage: profileImg.isNotEmpty
//                 ? NetworkImage(profileImg)
//                 : null,
//             child: profileImg.isEmpty
//                 ? Text(
//                     name.isNotEmpty ? name[0].toUpperCase() : "?",
//                     style: const TextStyle(fontSize: 22, color: Colors.white),
//                   )
//                 : null,
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Hi, $name 👋",
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 const SizedBox(height: 4),

//                 if (workerLevel.isNotEmpty)
//                   Text(
//                     workerLevel,
//                     style: const TextStyle(color: Colors.white, fontSize: 13),
//                   ),
//                 if (location.isNotEmpty)
//                   Text(
//                     location,
//                     style: const TextStyle(color: Colors.white70, fontSize: 11),
//                   ),
//                 const SizedBox(height: 6),
//                 Row(
//                   children: [
//                     const Icon(Icons.star, color: Colors.yellow, size: 18),
//                     Text(
//                       avgRating.toStringAsFixed(1),
//                       style: const TextStyle(color: Colors.white),
//                     ),
//                     Text(
//                       " ($ratingCount reviews)",
//                       style: const TextStyle(color: Colors.white70),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _statsRow(Map<String, int> stats) {
//     final pending = stats['pending'] ?? 0;
//     final active = stats['active'] ?? 0;
//     final done = stats['done'] ?? 0;
//     final total = stats['totaljobs'] ?? 0;
//     final reject = stats['reject'] ?? 0;
//     final requestToPay = stats['requestToPay'] ?? 0; // FIXED
//     completedJobsCount = stats['done'] ?? 0;

//     return Column(
//       children: [
//         Row(
//           children: [
//             _statBox("Pending", pending, Iconsax.timer, Colors.orange),
//             _statBox("Active", active, Iconsax.play, Colors.blue),
//           ],
//         ),
//         const SizedBox(height: 14),
//         Row(
//           children: [
//             _statBox("Completed", done, Iconsax.verify, Colors.green),
//             _statBox("Post Jobs", total, Iconsax.briefcase, Colors.purple),
//           ],
//         ),
//         const SizedBox(height: 14),
//         Row(
//           children: [
//             _statBox(
//               "Request To Pay",
//               requestToPay,
//               Iconsax.verify,
//               Colors.green,
//             ),
//             _statBox("Reject Jobs", reject, Iconsax.briefcase, Colors.purple),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _statBox(String label, int value, IconData icon, Color color) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 14),
//         margin: const EdgeInsets.symmetric(horizontal: 6),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(14),
//         ),
//         child: Column(
//           children: [
//             Icon(icon, size: 22, color: color),
//             Text(
//               "$value",
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             Text(label, style: const TextStyle(fontSize: 12)),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _sectionTitles(BuildContext context, String title) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     return Text(
//       title,
//       style: TextStyle(
//         fontSize: 16,
//         fontWeight: FontWeight.w700,
//         color: isDark ? Colors.white : Colors.black87,
//       ),
//     );
//   }

//   Widget _tipsCard(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: AppColors.button.withOpacity(0.18),
//               borderRadius: BorderRadius.circular(999),
//             ),
//             child: const Icon(Iconsax.trend_up, color: AppColors.button),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               "Respond quickly to new job offers, keep your profile updated, and maintain a high rating to get more work.",
//               style: TextStyle(
//                 fontSize: 12,
//                 height: 1.4,
//                 color: isDark ? Colors.grey[200] : Colors.grey[800],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:rxdart/rxdart.dart';

import 'package:shohozkaz/core/constants.dart';

class WorkerHomeDashboard extends StatefulWidget {
  const WorkerHomeDashboard({super.key});

  @override
  State<WorkerHomeDashboard> createState() => _WorkerHomeDashboardState();
}

class _WorkerHomeDashboardState extends State<WorkerHomeDashboard> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  int completedJobsCount = 0;

  // Helpers
  String s(dynamic v, [String fallback = ""]) {
    if (v == null) return fallback;
    if (v is String) return v;
    return v.toString();
  }

  num n(dynamic v, [num fallback = 0]) {
    if (v == null) return fallback;
    if (v is num) return v;
    return num.tryParse(v.toString()) ?? fallback;
  }

  // NEW — Auto-update worker rating based on posterId = workerId
  Future<void> updateWorkerRating(String uid, String workerLabel) async {
    final snap = await FirebaseFirestore.instance
        .collection('jobFeedback')
        .where('posterId', isEqualTo: uid) // **workerId**
        .get();

    if (snap.docs.isEmpty) return;

    double sum = 0;
    for (var d in snap.docs) {
      sum += (d['rating'] ?? 0);
    }

    double avg = sum / snap.docs.length;

    await FirebaseFirestore.instance.collection('userInfo').doc(uid).update({
      'avgWorkerRating': avg,
      'ratingWorkerCount': snap.docs.length,
      'workerLabel': workerLabel,
    });
  }

  // ================= STATS STREAM ===================
  Stream<Map<String, int>> statsStream(String uid) {
    final pending = FirebaseFirestore.instance
        .collection('pendingJobs')
        .where('posterId', isEqualTo: uid)
        .where('status', whereIn: ['pending', 'confirmed'])
        .snapshots();

    final active = FirebaseFirestore.instance
        .collection('openJobs')
        .where('posterId', isEqualTo: uid)
        .where('status', whereIn: ['open', 'in_progress', 'accepted'])
        .snapshots();

    final requestToPay = FirebaseFirestore.instance
        .collection('openJobs')
        .where('posterId', isEqualTo: uid)
        .where('status', isEqualTo: 'waiting_payment')
        .snapshots();

    final completed = FirebaseFirestore.instance
        .collection('completedJobs')
        .where('posterId', isEqualTo: uid)
        .where('status', isEqualTo: 'completed')
        .snapshots();

    final totalpost = FirebaseFirestore.instance
        .collection('jobs')
        .where('employerId', isEqualTo: uid)
        .snapshots();

    final reject = FirebaseFirestore.instance
        .collection('rejectJobs')
        .where('posterId', isEqualTo: uid)
        .where('status', isEqualTo: 'rejected')
        .snapshots();

    return Rx.combineLatest6(
      pending,
      active,
      completed,
      totalpost,
      reject,
      requestToPay,
      (p, a, c, d, e, f) => {
        'pending': p.size,
        'active': a.size,
        'done': c.size,
        'totaljobs': d.size,
        'reject': e.size,
        'requestToPay': f.size,
      },
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> activeJobs(String uid) {
    return FirebaseFirestore.instance
        .collection('openJobs')
        .where('applicantId', isEqualTo: uid)
        .where(
          'status',
          whereIn: [
            'open',
            'in_progress',
            'accepted',
            'waiting_payment',
            'completed',
          ],
        )
        .orderBy('requestedAt', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final uid = _firebaseAuth.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(body: Center(child: Text("User not logged in")));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark
        ? const Color(0xFF000000)
        : const Color(0xFFF7F7F7);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('userInfo')
          .doc(uid)
          .snapshots(),
      builder: (context, userSnap) {
        if (!userSnap.hasData || !userSnap.data!.exists) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 🔥 Auto-update rating here

        final user = userSnap.data!.data() ?? {};
        final status = s(user['status']);

        if (status == "banned" || status == "blocked") {
          return const Scaffold(
            body: Center(
              child: Text(
                "Your account is banned.\nPlease contact support.",
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final name = s(user['name'], "Worker");
        final profileImg = s(user['profileImage']);
        //final location = s(user['location']);
        final avgRating = n(user['avgWorkerRating']).toDouble();
        final ratingCount = n(user['ratingWorkerCount']).toInt();

        final totalCompleted = completedJobsCount;

        final String workerLabel;

        if (totalCompleted <= 0) {
          workerLabel = "Just Getting Started";
        } else if (totalCompleted <= 5) {
          workerLabel = "Rising Worker";
        } else if (totalCompleted <= 20) {
          workerLabel = "Skilled Worker";
        } else if (totalCompleted <= 50) {
          workerLabel = "Professional Worker";
        } else if (totalCompleted <= 99) {
          workerLabel = "Expert Worker";
        } else {
          workerLabel = "Master Level Worker";
        }

        // call rating update
        updateWorkerRating(uid, workerLabel);

        return Scaffold(
          backgroundColor: background,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async => setState(() {}),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _headerCard(
                      name: name,
                      workerLevel: workerLabel,
                      profileImg: profileImg,
                      avgRating: avgRating,
                      ratingCount: ratingCount,
                    ),

                    const SizedBox(height: 20),
                    _sectionTitles(context, "Worker Dashboard"),

                    const SizedBox(height: 20),

                    StreamBuilder<Map<String, int>>(
                      stream: statsStream(uid),
                      builder: (context, snap) {
                        if (!snap.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return _statsRow(snap.data!);
                      },
                    ),

                    const SizedBox(height: 20),
                    _sectionTitles(context, "Tips to earn more"),
                    const SizedBox(height: 8),
                    _tipsCard(
                      context,
                      "Respond quickly to new job offers, keep your profile updated, and maintain a high rating to get more work.",
                    ),
                    const SizedBox(height: 8),

                    _tipsCard(
                      context,
                      "Complete your tasks on time and communicate clearly with clients to build trust and receive better job opportunities.",
                    ),
                    const SizedBox(height: 8),

                    _tipsCard(
                      context,
                      "Improve your skills regularly and stay active on the platform to increase your chances of receiving more job offers.",
                    ),
                    const SizedBox(height: 30),

                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // UI — SAME AS YOUR CODE
  Widget _headerCard({
    required String name,
    required String workerLevel,
    required String profileImg,
    required double avgRating,
    required int ratingCount,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.button,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundImage: profileImg.isNotEmpty
                ? NetworkImage(profileImg)
                : null,
            child: profileImg.isEmpty
                ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : "?",
                    style: const TextStyle(fontSize: 22, color: Colors.white),
                  )
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hi, $name 👋",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  workerLevel,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),

                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.yellow, size: 18),
                    Text(
                      avgRating.toStringAsFixed(1),
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      " ($ratingCount reviews)",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsRow(Map<String, int> stats) {
    final pending = stats['pending'] ?? 0;
    final active = stats['active'] ?? 0;
    final done = stats['done'] ?? 0;
    final total = stats['totaljobs'] ?? 0;
    final reject = stats['reject'] ?? 0;
    final requestToPay = stats['requestToPay'] ?? 0;

    completedJobsCount = done;

    return Column(
      children: [
        Row(
          children: [
            _statBox("Pending", pending, Iconsax.timer, Colors.orange),
            _statBox("Active", active, Iconsax.play, Colors.blue),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _statBox("Completed", done, Iconsax.verify, Colors.green),
            _statBox("Post Jobs", total, Iconsax.briefcase, Colors.purple),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _statBox(
              "Request To Pay",
              requestToPay,
              Iconsax.verify,
              Colors.green,
            ),
            _statBox("Reject Jobs", reject, Iconsax.close_square, Colors.red),
          ],
        ),
      ],
    );
  }

  Widget _statBox(String label, int value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: color),
            Text(
              "$value",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitles(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _tipsCard(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.button.withOpacity(0.18),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Icon(Iconsax.trend_up, color: AppColors.button),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: isDark ? Colors.grey[200] : Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
