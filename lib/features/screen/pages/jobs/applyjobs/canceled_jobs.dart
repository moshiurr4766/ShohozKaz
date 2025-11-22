

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

class CanceledJobsTab extends StatefulWidget {
  final bool isUser; // <-- New parameter
  const CanceledJobsTab({super.key, required this.isUser});

  @override
  State<CanceledJobsTab> createState() => _CanceledJobsTabState();
}

class _CanceledJobsTabState extends State<CanceledJobsTab> {
  // Combine canceled jobs for both poster and applicant
  Stream<List<QueryDocumentSnapshot>> _getCanceledJobs(String uid) {
    final col = FirebaseFirestore.instance.collection('canceledJobs');
    final poster$ = col.where('posterId', isEqualTo: uid).snapshots();
    final applicant$ = col.where('applicantId', isEqualTo: uid).snapshots();

    return CombineLatestStream.combine2<QuerySnapshot, QuerySnapshot,
        List<QueryDocumentSnapshot>>(
      poster$,
      applicant$,
      (p, a) {
        final combined = [...p.docs, ...a.docs];
        // Sort newest first
        combined.sort((a, b) {
          final aTime = (a['canceledAt'] as Timestamp?)?.toDate() ?? DateTime(0);
          final bTime = (b['canceledAt'] as Timestamp?)?.toDate() ?? DateTime(0);
          return bTime.compareTo(aTime);
        });
        return combined;
      },
    );
  }

  Future<void> _reportCanceledJob(
      Map<String, dynamic> data, BuildContext context) async {
    final reasonController = TextEditingController();
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    final jobOrderId = data['jobOrderId'] ?? '';
    final isPoster = data['posterId'] == currentUid;

    try {
      final existingReports = await FirebaseFirestore.instance
          .collection('orderCancelReport')
          .where('reportedBy', isEqualTo: currentUid)
          .where('jobOrderId', isEqualTo: jobOrderId)
          .get();

      if (existingReports.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You have already reported this order.'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(14))),
          ),
        );
        return;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking reports: $e')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isPoster ? 'Poster Report' : 'Applicant Report',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: reasonController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText:
                  isPoster ? 'Enter reason (poster)' : 'Enter reason (applicant)',
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final reasonText = reasonController.text.trim();
    if (reasonText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a reason before submitting.')),
      );
      return;
    }

    final reportData = {
      'jobOrderId': jobOrderId,
      'jobTitle': data['jobTitle'] ?? '',
      'posterId': data['posterId'] ?? '',
      'applicantId': data['applicantId'] ?? '',
      'posterEmail': data['posterEmail'] ?? '',
      'applicantEmail': data['applicantEmail'] ?? '',
      'reportedBy': currentUid,
      'reportedAt': FieldValue.serverTimestamp(),
    };

    if (isPoster) {
      reportData['posterReason'] = reasonText;
    } else {
      reportData['applicantReason'] = reasonText;
    }

    try {
      await FirebaseFirestore.instance
          .collection('orderCancelReport')
          .add(reportData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Report submitted successfully!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting report: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final cardColor = theme.cardColor;
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF121212) : Colors.grey[50];
    final borderColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;

    return StreamBuilder<List<QueryDocumentSnapshot>>(
      stream: _getCanceledJobs(uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error loading canceled jobs.",
              style: TextStyle(color: theme.colorScheme.error),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: theme.colorScheme.primary),
          );
        }

        final jobs = snapshot.data ?? [];
        if (jobs.isEmpty) {
          return Center(
            child: Text(
              "No canceled jobs.",
              style: TextStyle(
                color: textColor.withOpacity(0.6),
                fontSize: 16,
              ),
            ),
          );
        }

        return Container(
          color: backgroundColor,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final data = jobs[index].data() as Map<String, dynamic>;
              final canceledAt = (data['canceledAt'] as Timestamp?)?.toDate();
              final canceledText = canceledAt != null
                  ? DateFormat('MMM dd, yyyy • hh:mm a').format(canceledAt)
                  : 'Unknown date';

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
                      Text(
                        data['jobTitle'] ?? 'Untitled Job',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text("Skill: ${data['skill'] ?? 'N/A'}",
                          style: TextStyle(color: Colors.grey)),
                      Text("Location: ${data['location'] ?? 'N/A'}",
                          style: TextStyle(color: Colors.grey)),
                      Text("Poster: ${data['posterEmail'] ?? 'N/A'}",
                          style: TextStyle(color: Colors.grey)),
                      Text("Applicant: ${data['applicantEmail'] ?? 'N/A'}",
                          style: TextStyle(color: Colors.grey)),
                      Text(
                        "Order ID: ${data['jobOrderId'] ?? 'N/A'}",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Canceled on: $canceledText",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Reason: ${data['cancelReason'] ?? data['reason'] ?? 'No reason provided'}",
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Only show button if isUser is true
                      if (widget.isUser)
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.flag_rounded, size: 18),
                            label: const Text("Report Order",
                                style: TextStyle(fontWeight: FontWeight.w600)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () => _reportCanceledJob(data, context),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
