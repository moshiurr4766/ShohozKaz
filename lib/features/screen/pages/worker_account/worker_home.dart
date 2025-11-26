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

  //  Verification variable
  String workerActiveStatus = "loading";
  String verificationStatus = "loading";

  //  Load verifyWorker status
  Stream<String> verificationStream(String uid) {
    return FirebaseFirestore.instance
        .collection("workerKyc")
        .doc(uid)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return "none";
          return doc["status"] ?? "none";
        });
  }

  Stream<String> userStatusStream(String uid) {
    return FirebaseFirestore.instance
        .collection("userInfo")
        .doc(uid)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return "none";
          return doc["status"] ?? "none";
        });
  }

  //Run once when widget opens
  @override
  void initState() {
    super.initState();
  }

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

  // STATS STREAM
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

        //  Auto-update rating here

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
                    StreamBuilder<String>(
                      stream: verificationStream(uid),
                      builder: (context, verifySnap) {
                        final vStatus = verifySnap.data ?? "loading";

                        return StreamBuilder<String>(
                          stream: userStatusStream(uid),
                          builder: (context, userSnap) {
                            final uStatus = userSnap.data ?? "loading";

                            return _headerCard(
                              name: name,
                              workerLevel: workerLabel,
                              profileImg: profileImg,
                              avgRating: avgRating,
                              ratingCount: ratingCount,
                              verificationStatus: vStatus,
                              userAccountStatus: uStatus, // <-- NEW
                            );
                          },
                        );
                      },
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

  // // UI — SAME AS YOUR CODE
  // Widget _headerCard({
  //   required String name,
  //   required String workerLevel,
  //   required String profileImg,
  //   required double avgRating,
  //   required int ratingCount,
  // }) {
  //   return Container(
  //     padding: const EdgeInsets.all(18),
  //     decoration: BoxDecoration(
  //       color: AppColors.button,
  //       borderRadius: BorderRadius.circular(18),
  //     ),
  //     child: Row(
  //       children: [
  //         CircleAvatar(
  //           radius: 32,
  //           backgroundImage: profileImg.isNotEmpty
  //               ? NetworkImage(profileImg)
  //               : null,
  //           child: profileImg.isEmpty
  //               ? Text(
  //                   name.isNotEmpty ? name[0].toUpperCase() : "?",
  //                   style: const TextStyle(fontSize: 22, color: Colors.white),
  //                 )
  //               : null,
  //         ),
  //         const SizedBox(width: 14),
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 "Hi, $name 👋",
  //                 style: const TextStyle(
  //                   color: Colors.white,
  //                   fontSize: 18,
  //                   fontWeight: FontWeight.w700,
  //                 ),
  //               ),
  //               const SizedBox(height: 4),
  //               Text(
  //                 workerLevel,
  //                 style: const TextStyle(color: Colors.white, fontSize: 13),
  //               ),

  //               const SizedBox(height: 6),
  //               Row(
  //                 children: [
  //                   const Icon(Icons.star, color: Colors.yellow, size: 18),
  //                   Text(
  //                     avgRating.toStringAsFixed(1),
  //                     style: const TextStyle(color: Colors.white),
  //                   ),
  //                   Text(
  //                     " ($ratingCount reviews)",
  //                     style: const TextStyle(
  //                       color: Colors.white70,
  //                       fontSize: 12,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _headerCard({
    required String name,
    required String workerLevel,
    required String profileImg,
    required double avgRating,
    required int ratingCount,
    required String verificationStatus,
    required String userAccountStatus,
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
                const SizedBox(height: 4),

                Row(
                  children: [
                    const SizedBox(height: 4),
                    _statusBadge("KYC: $verificationStatus"),

                    const SizedBox(width: 6),
                    _statusBadge("Account: $userAccountStatus"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String statusLabel) {
    Color bg;
    String label = statusLabel;

    if (statusLabel.contains("approved"))
      bg = Colors.green;
    else if (statusLabel.contains("pending"))
      bg = Colors.orange;
    else if (statusLabel.contains("rejected"))
      bg = Colors.red;
    else if (statusLabel.contains("active"))
      bg = Colors.green;
    else if (statusLabel.contains("suspended"))
      bg = Colors.red;
    else if (statusLabel.contains("banned"))
      bg = Colors.redAccent;
    else
      bg = Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
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
            _statBox(context, "Pending", pending, Iconsax.timer, Colors.orange),
            _statBox(context, "Active", active, Iconsax.play, Colors.blue),
          ],
        ),
        const SizedBox(height: 14),

        Row(
          children: [
            _statBox(context, "Completed", done, Iconsax.verify, Colors.green),
            _statBox(
              context,
              "Post Jobs",
              total,
              Iconsax.briefcase,
              Colors.purple,
            ),
          ],
        ),
        const SizedBox(height: 14),

        Row(
          children: [
            _statBox(
              context,
              "Request To Pay",
              requestToPay,
              Iconsax.verify,
              Colors.green,
            ),
            _statBox(
              context,
              "Reject Jobs",
              reject,
              Iconsax.close_square,
              Colors.red,
            ),
          ],
        ),
      ],
    );
  }

  // Widget _statBox(String label, int value, IconData icon, Color color) {
  //   return Expanded(
  //     child: Container(
  //       padding: const EdgeInsets.symmetric(vertical: 14),
  //       margin: const EdgeInsets.symmetric(horizontal: 6),
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(14),
  //       ),
  //       child: Column(
  //         children: [
  //           Icon(icon, size: 22, color: color),
  //           Text(
  //             "$value",
  //             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //           ),
  //           Text(label, style: const TextStyle(fontSize: 12)),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _statBox(
    BuildContext context,
    String label,
    int value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: isDark ? theme.colorScheme.surfaceVariant : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: color),
            Text(
              "$value",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
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
