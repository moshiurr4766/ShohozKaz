import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shohozkaz/core/constants.dart';
import 'package:shohozkaz/features/screen/pages/chatscreen/chat_page.dart';

class OpenJobsApplicantTab extends StatefulWidget {
  const OpenJobsApplicantTab({super.key});

  @override
  State<OpenJobsApplicantTab> createState() => _OpenJobsApplicantTabState();
}

class _OpenJobsApplicantTabState extends State<OpenJobsApplicantTab> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  Stream<QuerySnapshot> _applicantJobsStream() {
    return FirebaseFirestore.instance
        .collection('openJobs')
        .where('applicantId', isEqualTo: currentUser.uid)
        .snapshots();
  }

  Future<void> _markCompleted(Map<String, dynamic> data, String docId, BuildContext context) async {
    try {
      final jobData = {
        ...data,
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('completedJobs').add(jobData);
      await FirebaseFirestore.instance.collection('openJobs').doc(docId).delete();

      _showSnack(context, "Payment successful. Job completed.", true);
    } catch (e) {
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
      child: StreamBuilder<QuerySnapshot>(
        stream: _applicantJobsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Permission denied or query error.', style: TextStyle(color: textColor)));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No open jobs.', style: TextStyle(color: textColor.withOpacity(0.6))));
          }

          final jobs = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final doc = jobs[index];
              final data = doc.data() as Map<String, dynamic>;
              final docId = doc.id;
              final progress = data['progress'] ?? 'Not started';
              final contactEmail = data['posterEmail'] ?? 'Unknown';
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
                      Text("Poster: $contactEmail", style: TextStyle(color: Colors.grey)),
                      Text("Order ID: $orderId", style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 10),
                      Text("Progress: $progress", style: TextStyle(color: textColor.withOpacity(0.8))),
                      const SizedBox(height: 12),

                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatPage(
                                receiverId: data['posterId'],
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

                      if (status == 'waiting_payment')
                        ElevatedButton(
                          onPressed: () async {
                            _showSnack(context, "Processing payment...", true);
                            try {
                              await Future.delayed(const Duration(seconds: 2));
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
