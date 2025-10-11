




import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

class CompletedJobsTab extends StatefulWidget {
  const CompletedJobsTab({super.key});

  @override
  State<CompletedJobsTab> createState() => _CompletedJobsTabState();
}

class _CompletedJobsTabState extends State<CompletedJobsTab> {
  Stream<List<QueryDocumentSnapshot>> _getCompletedJobs(String uid) {
    final col = FirebaseFirestore.instance.collection('completedJobs');
    final poster$ = col.where('posterId', isEqualTo: uid).snapshots();
    final applicant$ = col.where('applicantId', isEqualTo: uid).snapshots();

    return CombineLatestStream.combine2<QuerySnapshot, QuerySnapshot, List<QueryDocumentSnapshot>>(
      poster$,
      applicant$,
      (p, a) => [...p.docs, ...a.docs],
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder<List<QueryDocumentSnapshot>>(
      stream: _getCompletedJobs(uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error loading completed jobs or permission denied.",
              style: TextStyle(color: colorScheme.error),
            ),
          );
        }

        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(color: colorScheme.primary),
          );
        }

        final jobs = snapshot.data!;
        if (jobs.isEmpty) {
          return const Center(child: Text("No completed jobs."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            final data = jobs[index].data() as Map<String, dynamic>;
            final completedAt = (data['completedAt'] as Timestamp?)?.toDate();
            final completedText = completedAt != null
                ? DateFormat('MMM dd, yyyy • hh:mm a').format(completedAt)
                : 'Unknown date';

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['jobTitle'] ?? 'Unknown Job',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Location: ${data['location'] ?? ''}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Completed on: $completedText",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Earnings: ${data['salary'] ?? '৳--'}",
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
