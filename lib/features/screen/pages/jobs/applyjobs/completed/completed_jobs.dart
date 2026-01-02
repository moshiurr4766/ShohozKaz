import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shohozkaz/core/constants.dart';
import 'package:shohozkaz/features/screen/pages/jobs/applyjobs/completed/cal_user_rating.dart';

class CompletedJobsTab extends StatefulWidget {
  final bool isUser; // <-- Parameter to filter poster/user
  const CompletedJobsTab({super.key, required this.isUser});

  @override
  State<CompletedJobsTab> createState() => _CompletedJobsTabState();
}

class _CompletedJobsTabState extends State<CompletedJobsTab> {
  // Combine both poster & applicant jobs
  Stream<List<QueryDocumentSnapshot>> _getCompletedJobs(String uid) {
    final col = FirebaseFirestore.instance.collection('completedJobs');
    final poster$ = col.where('posterId', isEqualTo: uid).snapshots();
    final applicant$ = col.where('applicantId', isEqualTo: uid).snapshots();

    return CombineLatestStream.combine2<
      QuerySnapshot,
      QuerySnapshot,
      List<QueryDocumentSnapshot>
    >(poster$, applicant$, (p, a) {
      final combined = [...p.docs, ...a.docs];
      combined.sort((a, b) {
        final aTime = (a['completedAt'] as Timestamp?)?.toDate() ?? DateTime(0);
        final bTime = (b['completedAt'] as Timestamp?)?.toDate() ?? DateTime(0);
        return bTime.compareTo(aTime);
      });

      // Filter based on isUser parameter
      final filtered = combined.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final isPoster = data['posterId'] == uid;
        return widget.isUser ? !isPoster : isPoster;
      }).toList();

      return filtered;
    });
  }

  // Feedback Dialog
  Future<void> _showFeedbackDialog(
    Map<String, dynamic> jobData,
    bool isPoster,
  ) async {
    final feedbackController = TextEditingController();
    double rating = 3.0;
    final currentUser = FirebaseAuth.instance.currentUser!;

    await showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final dark = theme.brightness == Brightness.dark;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight:
                      MediaQuery.of(context).size.height *
                      0.75, // prevents overflow
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: Container(
                    width: 340,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: dark
                            ? [const Color(0xFF1E1E1E), const Color(0xFF2C2C2C)]
                            : [Colors.white, Colors.grey.shade100],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        //  HEADER TEXT
                        Text(
                          "Your opinion matters to us!",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: dark ? Colors.white : Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Text(
                          isPoster
                              ? "Rate the worker’s performance"
                              : "Rate the employer’s experience",
                          style: TextStyle(
                            color: dark ? Colors.white70 : Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 20),

                        //  STARS
                        StatefulBuilder(
                          builder: (context, setState) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (i) {
                                return IconButton(
                                  onPressed: () {
                                    setState(() => rating = (i + 1).toDouble());
                                  },
                                  icon: Icon(
                                    i < rating
                                        ? Icons.star_rounded
                                        : Icons.star_border_rounded,
                                    color: AppColors.button,
                                    size: 32,
                                  ),
                                );
                              }),
                            );
                          },
                        ),

                        const SizedBox(height: 12),

                        //  FEEDBACK INPUT
                        TextField(
                          controller: feedbackController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: "Share your feedback...",
                            filled: true,
                            fillColor: dark
                                ? Colors.grey[800]
                                : Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        //  RATE NOW BUTTON
                        GestureDetector(
                          onTap: () async {
                            Navigator.pop(context);
                            await _submitFeedback(
                              jobData,
                              feedbackController.text.trim(),
                              rating,
                              isPoster,
                              currentUser.uid,
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: AppColors.button,
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              "Rate now",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        //  MAYBE LATER BUTTON
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "Maybe later",
                            style: TextStyle(
                              color: dark ? Colors.white70 : Colors.black54,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // Submit Feedback with setState refresh
  Future<void> _submitFeedback(
    Map<String, dynamic> jobData,
    String feedback,
    double rating,
    bool isPoster,
    String currentUid,
  ) async {
    final firestore = FirebaseFirestore.instance;
    final jobId = jobData['jobId'] ?? '';
    final jobOrderId = jobData['jobOrderId'] ?? '';
    final posterId = jobData['posterId'];
    final applicantId = jobData['applicantId'];

    try {
      if (isPoster) {
        await firestore.collection('userFeedback').add({
          'jobId': jobId,
          'jobOrderId': jobOrderId,
          'posterId': posterId,
          'posterEmail': jobData['posterEmail'],
          'userId': applicantId,
          'userEmail': jobData['applicantEmail'],
          'feedback': feedback,
          'rating': rating,
          'givenBy': currentUid,
          'createdAt': FieldValue.serverTimestamp(),
        });

        setState(() {}); // <-- Refresh UI instantly
        _showThankYouDialog(ratedUserId: applicantId);
      } else {
        await firestore.collection('jobFeedback').add({
          'jobId': jobId,
          'jobOrderId': jobOrderId,
          'posterId': posterId,
          'posterEmail': jobData['posterEmail'],
          'userId': applicantId,
          'userEmail': jobData['applicantEmail'],
          'feedback': feedback,
          'rating': rating,
          'givenBy': currentUid,
          'createdAt': FieldValue.serverTimestamp(),
        });

        setState(() {}); // <-- Refresh UI instantly
        _showThankYouDialog();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error submitting feedback: $e')));
    }
  }

  // Thank You Popup
  void _showThankYouDialog({String? ratedUserId}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: AppColors.button, size: 60),
              const SizedBox(height: 10),
              const Text(
                "Thank you!",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.button,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Your feedback has been received successfully.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color.fromARGB(255, 255, 138, 54),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  if (ratedUserId != null) {
                    final calc = UserRatingCalculator();
                    await calc.updateUserRating(ratedUserId);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.button,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size(120, 40),
                ),
                child: const Text(
                  "Close",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF121212) : Colors.grey[50];
    final borderColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;

    return StreamBuilder<List<QueryDocumentSnapshot>>(
      stream: _getCompletedJobs(uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error loading completed jobs or permission denied.",
              style: TextStyle(color: theme.colorScheme.error),
            ),
          );
        }

        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(color: theme.colorScheme.primary),
          );
        }

        final jobs = snapshot.data!;
        if (jobs.isEmpty) {
          return const Center(child: Text("No completed jobs."));
        }

        return Container(
          color: backgroundColor,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final data = jobs[index].data() as Map<String, dynamic>;
              final completedAt = (data['completedAt'] as Timestamp?)?.toDate();
              final completedText = completedAt != null
                  ? DateFormat('MMM dd, yyyy • hh:mm a').format(completedAt)
                  : 'Unknown date';
              final isPoster = data['posterId'] == uid;

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
                        data['jobTitle'] ?? 'Unknown Job',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Skill: ${data['skill'] ?? ''}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Location: ${data['location'] ?? ''}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Order Id: ${data['jobOrderId'] ?? ''}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                      Text(
                        "Completed on: $completedText",
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),

                      // Check if already rated
                      FutureBuilder<QuerySnapshot>(
                        future: FirebaseFirestore.instance
                            .collection(
                              isPoster ? 'userFeedback' : 'jobFeedback',
                            )
                            .where('jobId', isEqualTo: data['jobId'])
                            .where('jobOrderId', isEqualTo: data['jobOrderId'])
                            .where('givenBy', isEqualTo: uid)
                            .get(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox.shrink();
                          }
                          final alreadyRated = snapshot.data!.docs.isNotEmpty;

                          return Center(
                            child: alreadyRated
                                ? const Text(
                                    "You have already rated this job.",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  )
                                : ElevatedButton.icon(
                                    onPressed: () =>
                                        _showFeedbackDialog(data, isPoster),
                                    icon: const Icon(
                                      Icons.star_rate_rounded,
                                      size: 18,
                                    ),
                                    label: Text(
                                      isPoster
                                          ? "Rate Employer"
                                          : "Rate Worker",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: AppColors.button,
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      minimumSize: const Size(
                                        double.infinity,
                                        45,
                                      ),
                                    ),
                                  ),
                          );
                        },
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
