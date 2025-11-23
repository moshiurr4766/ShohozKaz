

//Testing 


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shohozkaz/core/constants.dart';
import 'package:shohozkaz/features/screen/pages/chatscreen/chat_page.dart';

class OpenJobsTab extends StatefulWidget {
  final bool isUser; // <-- New parameter
  const OpenJobsTab({super.key, required this.isUser});

  @override
  State<OpenJobsTab> createState() => _OpenJobsTabState();
}

class _OpenJobsTabState extends State<OpenJobsTab> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  Stream<QuerySnapshotMock> _openJobsStream() {
    final firestore = FirebaseFirestore.instance;

    final posterStream =
        firestore.collection('openJobs').where('posterId', isEqualTo: currentUser.uid).snapshots();
    final applicantStream =
        firestore.collection('openJobs').where('applicantId', isEqualTo: currentUser.uid).snapshots();

    return Rx.combineLatest2(
      posterStream,
      applicantStream,
      (QuerySnapshot a, QuerySnapshot b) {
        final docs = [...a.docs, ...b.docs];
        docs.sort((a, b) {
          final aTime = (a['acceptedAt'] as Timestamp?)?.toDate() ?? DateTime(0);
          final bTime = (b['acceptedAt'] as Timestamp?)?.toDate() ?? DateTime(0);
          return bTime.compareTo(aTime);
        });
        return QuerySnapshotMock(docs);
      },
    );
  }

  Future<void> _updateProgress(String docId, String newProgress, BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('openJobs').doc(docId).update({
        'progress': newProgress,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _showSnack(context, "Progress updated: $newProgress", true);
    } catch (e) {
      _showSnack(context, "Error updating progress: $e", false);
    }
  }

  Future<void> _confirmComplete(Map<String, dynamic> data, String docId, BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Confirm Completion"),
        content: const Text("Are you sure this job is completed?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("No")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.button,
              foregroundColor: Colors.white,
            ),
            child: const Text("Yes, Complete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _markWaitingPayment(data, docId);
      _showSnack(context, "Waiting for user payment.", true);
    }
  }

  Future<void> _markWaitingPayment(Map<String, dynamic> data, String docId) async {
    try {
      await FirebaseFirestore.instance.collection('openJobs').doc(docId).update({
        'status': 'waiting_payment',
        'completedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating to waiting_payment: $e');
    }
  }

  Future<void> _cancelJob(Map<String, dynamic> data, String docId, BuildContext context) async {
    final reasonController = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Cancel Job'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Are you sure you want to cancel this job?"),
              const SizedBox(height: 10),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Yes, Cancel'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        final cancelReason =
            reasonController.text.trim().isEmpty ? 'Canceled by poster' : reasonController.text.trim();

        final cancelData = {
          ...data,
          'status': 'canceled',
          'cancelReason': cancelReason,
          'jobOrderId': data['jobOrderId'] ?? docId,
          'posterId': data['posterId'],
          //'jobId':data['jobId'],
          'applicantId': data['applicantId'],
          'canceledAt': FieldValue.serverTimestamp(),
        };

        await FirebaseFirestore.instance.collection('canceledJobs').add(cancelData);
        await FirebaseFirestore.instance.collection('openJobs').doc(docId).delete();

        _showSnack(context, "Job canceled successfully.", true);
      } catch (e) {
        _showSnack(context, "Error: $e", false);
      }
    }
  }

  Future<void> _markCompleted(Map<String, dynamic> data, String docId, BuildContext context) async {
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

      _showSnack(context, "Payment successful. Job completed.", true);
    } catch (e) {
      debugPrint('Error completing job: $e');
      _showSnack(context, "Error completing job: $e", false);
    }
  }

  void _showSnack(BuildContext context, String msg, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: success ? AppColors.button : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final cardColor = theme.cardColor;
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF121212) : Colors.grey[50];
    final borderColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;

    return Container(
      color: backgroundColor,
      child: StreamBuilder<QuerySnapshotMock>(
        stream: _openJobsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text('Permission denied or query error.', style: TextStyle(color: textColor)));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text('No open jobs.', style: TextStyle(color: textColor.withOpacity(0.6))));
          }

          final jobs = snapshot.data!.docs;

          // Filter based on isUser
          final filteredJobs = jobs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final isPoster = data['posterId'] == currentUser.uid;
            return widget.isUser ? !isPoster : isPoster;
          }).toList();

          if (filteredJobs.isEmpty) {
            return Center(
                child: Text('No jobs to show.', style: TextStyle(color: textColor.withOpacity(0.6))));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredJobs.length,
            itemBuilder: (context, index) {
              final doc = filteredJobs[index];
              final data = doc.data() as Map<String, dynamic>;
              final docId = doc.id;
              final isPoster = data['posterId'] == currentUser.uid;
              final progress = data['progress'] ?? 'Not started';
              final contactEmail = isPoster
                  ? (data['applicantEmail'] ?? 'Unknown')
                  : (data['posterEmail'] ?? 'Unknown');
              final skill = data['skill'] ?? 'N/A';
              final location = data['location'] ?? 'Unknown';
              final orderId = data['jobOrderId'] ?? docId;
              final status = data['status'] ?? 'open';

              return Card(
                color: cardColor,
                elevation: 4,
                shadowColor: isDark ? Colors.black54 : Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: borderColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['jobTitle'] ?? 'Untitled',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                      const SizedBox(height: 4),
                      Text("Skill: $skill", style: TextStyle(color: Colors.grey)),
                      Text("Location: $location", style: TextStyle(color: Colors.grey)),
                      Text("${isPoster ? 'Applicant' : 'Poster'}: $contactEmail",
                          style: TextStyle(color: Colors.grey)),
                      Text("Order ID: $orderId", style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 10),

                      if (isPoster)
                        if (status == 'waiting_payment')
                          Text("Waiting for user payment",
                              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600, fontSize: 16))
                        else
                          DropdownButtonFormField<String>(
                            value: progress,
                            items: const [
                              DropdownMenuItem(value: 'Not started', child: Text('Not started')),
                              DropdownMenuItem(value: 'Started', child: Text('Started')),
                              DropdownMenuItem(value: 'In progress', child: Text('In progress')),
                              DropdownMenuItem(value: 'Almost done', child: Text('Almost done')),
                              DropdownMenuItem(value: 'Completed', child: Text('Completed')),
                            ],
                            onChanged: (val) {
                              if (val != null) _updateProgress(docId, val, context);
                            },
                            decoration: InputDecoration(
                              labelText: 'Progress',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          )
                      else
                        Text("Progress: $progress",
                            style: TextStyle(color: textColor.withOpacity(0.8))),
                      const SizedBox(height: 12),

                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatPage(
                                receiverId: isPoster ? data['applicantId'] : data['posterId'],
                                receiverEmail: contactEmail,
                              ),
                            ),
                          );
                        },
                        icon: Icon(Icons.chat_bubble_outline, color: AppColors.button),
                        label: const Text("Chat", style: TextStyle(fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.button, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          minimumSize: const Size(double.infinity, 45),
                        ),
                      ),
                      const SizedBox(height: 10),

                      if (isPoster)
                        if (status == 'waiting_payment')
                          const SizedBox.shrink()
                        else
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _confirmComplete(data, docId, context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.button,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    minimumSize: const Size(double.infinity, 45),
                                  ),
                                  child: const Text("Request To Pay",
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _cancelJob(data, docId, context),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.red, width: 1.5),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    minimumSize: const Size(double.infinity, 45),
                                  ),
                                  child: const Text("Cancel",
                                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ],
                          )
                      else if (status == 'waiting_payment')
                        ElevatedButton(
                          onPressed: () async {
                            _showSnack(context, "Processing payment...", true);
                            try {
                              await Future.delayed(const Duration(seconds: 2)); // Simulate payment
                              await _markCompleted(data, docId, context);
                            } catch (e) {
                              _showSnack(context, "Payment failed: $e", false);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.button,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            minimumSize: const Size(double.infinity, 45),
                          ),
                          child: const Text("Pay Now",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        )
                      else if (status == 'completed')
                        Text("Payment Completed",
                            style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 16)),
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

class QuerySnapshotMock {
  final List<QueryDocumentSnapshot> docs;
  QuerySnapshotMock(this.docs);
}
