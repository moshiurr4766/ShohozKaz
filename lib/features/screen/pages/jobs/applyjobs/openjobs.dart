






import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shohozkaz/core/constants.dart';

class OpenJobsTab extends StatelessWidget {
  const OpenJobsTab({super.key});

  // Stream for open jobs (poster or applicant)
  Stream<QuerySnapshot> _openJobsStream(String uid) {
    return FirebaseFirestore.instance
        .collection('openJobs')
        .where(Filter.or(
          Filter('posterId', isEqualTo: uid),
          Filter('applicantId', isEqualTo: uid),
        ))
        .snapshots();
  }

  //  Mark job as completed
  Future<void> _markCompleted(
      Map<String, dynamic> data, String docId, BuildContext context) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final jobData = {
        ...data,
        'posterId': data['posterId'] ?? currentUser.uid,
        'posterEmail': data['posterEmail'] ?? currentUser.email,
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('completedJobs').doc().set(jobData);
      await FirebaseFirestore.instance.collection('openJobs').doc(docId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Job marked as completed.')),
      );
    } catch (e) {
      debugPrint('Error completing job: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error completing job: $e')),
      );
    }
  }

  // ✅ Cancel job
  Future<void> _cancelJob(
      Map<String, dynamic> data, String docId, BuildContext context) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final jobData = {
        ...data,
        'posterId': data['posterId'] ?? currentUser.uid,
        'posterEmail': data['posterEmail'] ?? currentUser.email,
        'status': 'canceled',
        'reason': 'Job canceled by poster',
        'canceledAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('canceledJobs').doc().set(jobData);
      await FirebaseFirestore.instance.collection('openJobs').doc(docId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Job canceled successfully.')),
      );
    } catch (e) {
      debugPrint('Error canceling job: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error canceling job: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    //final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder<QuerySnapshot>(
      stream: _openJobsStream(uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Permission denied or query error.'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No open jobs.'));
        }

        final jobs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            final doc = jobs[index];
            final data = doc.data() as Map<String, dynamic>;
            final docId = doc.id;
            final isPoster = data['posterId'] == uid;

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['jobTitle'] ?? 'Untitled Job',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text("Location: ${data['location'] ?? ''}"),
                    const SizedBox(height: 10),
                    if (isPoster)
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () =>
                                  _markCompleted(data, docId, context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.button,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Mark Completed'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _cancelJob(data, docId, context),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.red),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      const Text(
                        'Job in progress...',
                        style: TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                          fontSize: 13,
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
