import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shohozkaz/core/constants.dart';
import 'package:iconsax/iconsax.dart';

class RejectedJobsScreen extends StatefulWidget {
  const RejectedJobsScreen({super.key});

  @override
  State<RejectedJobsScreen> createState() => _RejectedJobsScreenState();
}

class _RejectedJobsScreenState extends State<RejectedJobsScreen> {
  Stream<QuerySnapshot> _rejectedJobsStream(String uid) {
    final firestore = FirebaseFirestore.instance;

    // Keep logic identical — only UI is changed.
    return firestore
        .collection('rejectJobs')
        .where(Filter.or(
          Filter('posterId', isEqualTo: uid),
          Filter('applicantId', isEqualTo: uid),
        ))
        //.orderBy('rejectedAt', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isDark ? Colors.black : Colors.grey.shade100;
    final cardColor = isDark ? Colors.grey.shade900 : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Rejected'),
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _rejectedJobsStream(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Permission denied or data error.',
                style: TextStyle(color: textColor),
              ),
            );
          }

          final jobs = snapshot.data?.docs ?? [];
          if (jobs.isEmpty) {
            return Center(
              child: Text(
                'No rejected jobs yet.',
                style: TextStyle(color: subTextColor),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final data = jobs[index].data() as Map<String, dynamic>;

              final jobTitle = data['jobTitle'] ?? 'Unknown Job';
              final location = data['location'] ?? 'N/A';
              final skill = data['skill'] ?? 'N/A';
              final role = data['posterId'] == uid
                  ? 'Rejected Applicant'
                  : 'Rejected Job';
              final rejectedAt = (data['rejectedAt'] != null)
                  ? (data['rejectedAt'] as Timestamp)
                      .toDate()
                      .toLocal()
                      .toString()
                  : 'N/A';

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withOpacity(0.4)
                          : Colors.grey.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 42,
                            width: 42,
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Iconsax.close_circle,
                                color: Colors.redAccent),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              jobTitle,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Iconsax.location, size: 15, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              "Location: $location",
                              style: TextStyle(
                                color: subTextColor,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Iconsax.briefcase, size: 15, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              "Skill: $skill",
                              style: TextStyle(
                                color: subTextColor,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Role: $role",
                        style: TextStyle(
                          color: AppColors.button,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Iconsax.clock, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              "Rejected at: $rejectedAt",
                              style: TextStyle(
                                color: subTextColor,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}



