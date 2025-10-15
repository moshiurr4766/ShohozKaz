// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
// import 'package:shohozkaz/core/constants.dart';
// import 'package:shohozkaz/features/screen/pages/jobs/applyjobs/completed/cal_user_rating.dart';

// class CompletedJobsPosterTab extends StatefulWidget {
//   const CompletedJobsPosterTab({super.key});

//   @override
//   State<CompletedJobsPosterTab> createState() => _CompletedJobsPosterTabState();
// }

// class _CompletedJobsPosterTabState extends State<CompletedJobsPosterTab> {
//   Stream<List<QueryDocumentSnapshot>> _getCompletedJobs(String uid) {
//     return FirebaseFirestore.instance
//         .collection('completedJobs')
//         .where('posterId', isEqualTo: uid)
//         .snapshots()
//         .map((snap) => snap.docs);
//   }

//   Future<void> _showFeedbackDialog(Map<String, dynamic> jobData) async {
//     final feedbackController = TextEditingController();
//     double rating = 3.0;
//     final currentUser = FirebaseAuth.instance.currentUser!;

//     await showDialog(
//       context: context,
//       builder: (context) {
//         final theme = Theme.of(context);
//         final dark = theme.brightness == Brightness.dark;
//         return Dialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           child: Container(
//             width: 340,
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(20),
//               gradient: LinearGradient(
//                 colors: dark
//                     ? [const Color(0xFF1E1E1E), const Color(0xFF2C2C2C)]
//                     : [Colors.white, Colors.grey.shade100],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text("Your opinion matters to us!",
//                     style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 18,
//                         color: dark ? Colors.white : Colors.black87)),
//                 const SizedBox(height: 16),
//                 Text("Rate the worker’s performance",
//                     style: TextStyle(
//                         color: dark ? Colors.white70 : Colors.grey[700],
//                         fontSize: 14)),
//                 const SizedBox(height: 20),
//                 StatefulBuilder(builder: (context, setState) {
//                   return Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: List.generate(5, (i) {
//                       return IconButton(
//                         onPressed: () {
//                           setState(() => rating = (i + 1).toDouble());
//                         },
//                         icon: Icon(
//                           i < rating
//                               ? Icons.star_rounded
//                               : Icons.star_border_rounded,
//                           color: AppColors.button,
//                           size: 32,
//                         ),
//                       );
//                     }),
//                   );
//                 }),
//                 const SizedBox(height: 12),
//                 TextField(
//                   controller: feedbackController,
//                   maxLines: 3,
//                   decoration: InputDecoration(
//                     hintText: "Share your feedback...",
//                     filled: true,
//                     fillColor: dark ? Colors.grey[800] : Colors.grey[200],
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide.none),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 GestureDetector(
//                   onTap: () async {
//                     Navigator.pop(context);
//                     await _submitFeedback(jobData, feedbackController.text.trim(),
//                         rating, currentUser.uid);
//                   },
//                   child: Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(12),
//                       color: AppColors.button,
//                     ),
//                     alignment: Alignment.center,
//                     child: const Text("Rate now",
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16)),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: Text("Maybe later",
//                       style: TextStyle(
//                           color: dark ? Colors.white70 : Colors.black54,
//                           fontSize: 13)),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Future<void> _submitFeedback(
//       Map<String, dynamic> jobData, String feedback, double rating, String uid) async {
//     final firestore = FirebaseFirestore.instance;
//     final jobId = jobData['jobOrderId'] ?? '';
//     final posterId = jobData['posterId'];
//     final applicantId = jobData['applicantId'];

//     try {
//       await firestore.collection('userFeedback').add({
//         'jobId': jobId,
//         'posterId': posterId,
//         'posterEmail': jobData['posterEmail'],
//         'userId': applicantId,
//         'userEmail': jobData['applicantEmail'],
//         'feedback': feedback,
//         'rating': rating,
//         'givenBy': uid,
//         'createdAt': FieldValue.serverTimestamp(),
//       });
//       _showThankYouDialog(ratedUserId: applicantId);
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Error submitting feedback: $e')));
//     }
//   }

//   void _showThankYouDialog({String? ratedUserId}) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(mainAxisSize: MainAxisSize.min, children: [
//             const Icon(Icons.check_circle, color: AppColors.button, size: 60),
//             const SizedBox(height: 10),
//             const Text("Thank you!",
//                 style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 18,
//                     color: AppColors.button)),
//             const SizedBox(height: 6),
//             const Text("Your feedback has been received successfully.",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                     color: Color.fromARGB(255, 255, 138, 54), fontSize: 13)),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () async {
//                 Navigator.pop(context);
//                 if (ratedUserId != null) {
//                   final calc = UserRatingCalculator();
//                   await calc.updateUserRating(ratedUserId);
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.button,
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8)),
//                 minimumSize: const Size(120, 40),
//               ),
//               child: const Text("Close",
//                   style: TextStyle(color: Colors.white)),
//             ),
//           ]),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final uid = FirebaseAuth.instance.currentUser!.uid;
//     final theme = Theme.of(context);
//     final cardColor = theme.cardColor;
//     final isDark = theme.brightness == Brightness.dark;
//     final backgroundColor = isDark ? const Color(0xFF121212) : Colors.grey[50];
//     final borderColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;

//     return StreamBuilder<List<QueryDocumentSnapshot>>(
//       stream: _getCompletedJobs(uid),
//       builder: (context, snapshot) {
//         if (snapshot.hasError) {
//           return Center(
//               child: Text("Error loading completed jobs or permission denied.",
//                   style: TextStyle(color: theme.colorScheme.error)));
//         }
//         if (!snapshot.hasData) {
//           return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
//         }
//         final jobs = snapshot.data!;
//         if (jobs.isEmpty) return const Center(child: Text("No completed jobs."));

//         return Container(
//           color: backgroundColor,
//           child: ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: jobs.length,
//             itemBuilder: (context, index) {
//               final data = jobs[index].data() as Map<String, dynamic>;
//               final completedAt = (data['completedAt'] as Timestamp?)?.toDate();
//               final completedText = completedAt != null
//                   ? DateFormat('MMM dd, yyyy • hh:mm a').format(completedAt)
//                   : 'Unknown date';

//               return Card(
//                 color: cardColor,
//                 elevation: 4,
//                 shadowColor: isDark ? Colors.black54 : Colors.grey[300],
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                     side: BorderSide(color: borderColor)),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(data['jobTitle'] ?? 'Unknown Job',
//                             style: const TextStyle(
//                                 fontWeight: FontWeight.bold, fontSize: 17)),
//                         const SizedBox(height: 4),
//                         Text("Skill: ${data['skill'] ?? ''}",
//                             style: const TextStyle(color: Colors.grey)),
//                         const SizedBox(height: 4),
//                         Text("Location: ${data['location'] ?? ''}",
//                             style: const TextStyle(color: Colors.grey)),
//                         const SizedBox(height: 4),
//                         Text("Order Id: ${data['jobOrderId'] ?? ''}",
//                             style: const TextStyle(color: Colors.grey)),
//                         Text("Completed on: $completedText",
//                             style: const TextStyle(color: Colors.grey)),
//                         const SizedBox(height: 16),
//                         Center(
//                           child: ElevatedButton.icon(
//                             onPressed: () => _showFeedbackDialog(data),
//                             icon: const Icon(Icons.star_rate_rounded, size: 18),
//                             label: const Text("Rate Worker",
//                                 style:
//                                     TextStyle(fontWeight: FontWeight.w600)),
//                             style: OutlinedButton.styleFrom(
//                               side: BorderSide(
//                                   color: AppColors.button, width: 1.5),
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12)),
//                               minimumSize: const Size(double.infinity, 45),
//                             ),
//                           ),
//                         ),
//                       ]),
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }


























import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:shohozkaz/core/constants.dart';
import 'package:shohozkaz/features/screen/pages/jobs/applyjobs/completed/cal_user_rating.dart';

class CompletedJobsPosterTab extends StatefulWidget {
  const CompletedJobsPosterTab({super.key});

  @override
  State<CompletedJobsPosterTab> createState() => _CompletedJobsPosterTabState();
}

class _CompletedJobsPosterTabState extends State<CompletedJobsPosterTab> {
  final Map<String, bool> _ratingCache = {}; // Track rated jobs locally

  Stream<List<QueryDocumentSnapshot>> _getPosterCompletedJobs(String uid) {
    final col = FirebaseFirestore.instance.collection('completedJobs');
    final poster$ = col.where('posterId', isEqualTo: uid).snapshots();

    return poster$.map((snapshot) {
      final docs = snapshot.docs;
      docs.sort((a, b) {
        final aTime = (a['completedAt'] as Timestamp?)?.toDate() ?? DateTime(0);
        final bTime = (b['completedAt'] as Timestamp?)?.toDate() ?? DateTime(0);
        return bTime.compareTo(aTime);
      });
      return docs;
    });
  }

  Future<void> _showFeedbackDialog(Map<String, dynamic> jobData) async {
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
          child: Container(
            width: 340,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: dark
                    ? [const Color(0xFF1E1E1E), const Color(0xFF2C2C2C)]
                    : [Colors.white, Colors.grey.shade100],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Your opinion matters to us!",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: dark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Rate the worker’s performance",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 20),
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
                TextField(
                  controller: feedbackController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Share your feedback...",
                    filled: true,
                    fillColor: dark ? Colors.grey[800] : Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);
                    await _submitFeedback(
                      jobData,
                      feedbackController.text.trim(),
                      rating,
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
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Maybe later",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitFeedback(
    Map<String, dynamic> jobData,
    String feedback,
    double rating,
    String currentUid,
  ) async {
    final firestore = FirebaseFirestore.instance;
    final jobId = jobData['jobOrderId'] ?? '';
    final applicantId = jobData['applicantId'];
    try {
      await firestore.collection('userFeedback').add({
        'jobId': jobId,
        'posterId': jobData['posterId'],
        'posterEmail': jobData['posterEmail'],
        'userId': applicantId,
        'userEmail': jobData['applicantEmail'],
        'feedback': feedback,
        'rating': rating,
        'givenBy': currentUid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update local cache so UI refreshes immediately
      setState(() {
        _ratingCache[jobId] = true;
      });

      _showThankYouDialog(applicantId);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showThankYouDialog(String ratedUserId) {
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
                  final calc = UserRatingCalculator();
                  await calc.updateUserRating(ratedUserId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.button,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size(120, 40),
                ),
                child: const Text("Close"),
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
      stream: _getPosterCompletedJobs(uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Error loading completed jobs."));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final jobs = snapshot.data!;
        if (jobs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.work_off_rounded,
                  size: 80,
                  color: theme.colorScheme.primary.withOpacity(0.6),
                ),
                const SizedBox(height: 16),
                Text(
                  "No completed jobs yet",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Once you complete a job, it will appear here.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
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
              final completedAt = (data['completedAt'] as Timestamp?)?.toDate();
              final completedText = completedAt != null
                  ? DateFormat('MMM dd, yyyy • hh:mm a').format(completedAt)
                  : 'Unknown date';

              final jobId = data['jobOrderId'];

              return Card(
                color: cardColor,
                elevation: 4,
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
                      Text(
                        "Skill: ${data['skill'] ?? ''}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                      Text(
                        "Location: ${data['location'] ?? ''}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                      Text(
                        "Order Id: ${data['jobOrderId'] ?? ''}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                      Text(
                        "Completed on: $completedText",
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: _ratingCache[jobId] == true
                            ? Text(
                                "You have already rated this job.",
                                style: TextStyle(
                                  color: Colors.green[600],
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : FutureBuilder<QuerySnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection('userFeedback')
                                    .where('jobId', isEqualTo: jobId)
                                    .where('givenBy', isEqualTo: uid)
                                    .get(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData)
                                    return const SizedBox(height: 45);
                                  final alreadyRated =
                                      snapshot.data!.docs.isNotEmpty;
                                  if (alreadyRated)
                                    _ratingCache[jobId] = true;
                                  return alreadyRated
                                      ? Text(
                                          "You have already rated this job.",
                                          style: TextStyle(
                                            color: Colors.green[600],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        )
                                      : ElevatedButton.icon(
                                          onPressed: () =>
                                              _showFeedbackDialog(data),
                                          icon: const Icon(
                                            Icons.star_rate_rounded,
                                            size: 18,
                                          ),
                                          label: const Text(
                                            "Rate Worker",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(
                                              color: AppColors.button,
                                              width: 1.5,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            minimumSize: const Size(
                                              double.infinity,
                                              45,
                                            ),
                                          ),
                                        );
                                },
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
