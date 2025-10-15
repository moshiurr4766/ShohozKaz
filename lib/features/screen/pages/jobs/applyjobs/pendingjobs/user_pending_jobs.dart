// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:shohozkaz/core/constants.dart';
// import 'package:shohozkaz/features/screen/pages/chatscreen/chat_page.dart';

// class UserPendingJobsScreen extends StatefulWidget {
//   const UserPendingJobsScreen({super.key});

//   @override
//   State<UserPendingJobsScreen> createState() => _UserPendingJobsScreenState();
// }

// class _UserPendingJobsScreenState extends State<UserPendingJobsScreen> {
//   final String currentUid = FirebaseAuth.instance.currentUser!.uid;

//   Stream<QuerySnapshot> _pendingJobsStream() {
//     return FirebaseFirestore.instance
//         .collection('pendingJobs')
//         .where('applicantId', isEqualTo: currentUid)
//         .snapshots();
//   }

//   Future<void> _confirmJob(Map<String, dynamic> data) async {
//     try {
//       await FirebaseFirestore.instance
//           .collection('pendingJobs')
//           .doc(data['docId'])
//           .update({
//         'status': 'confirmed',
//         'confirmedAt': FieldValue.serverTimestamp(),
//       });
//       _showSnack('Job confirmed. Waiting for employer acceptance.', true);
//     } catch (e) {
//       _showSnack('Error confirming job: $e', false);
//     }
//   }

//   Future<void> _rejectJob(Map<String, dynamic> data) async {
//     try {
//       await FirebaseFirestore.instance.collection('rejectJobs').doc().set({
//         ...data,
//         'status': 'rejected',
//         'reason': 'Rejected by applicant',
//         'rejectedAt': FieldValue.serverTimestamp(),
//       });

//       await FirebaseFirestore.instance
//           .collection('pendingJobs')
//           .doc(data['docId'])
//           .delete();

//       _showSnack('Job rejected successfully.', true);
//     } catch (e) {
//       _showSnack('Error rejecting job: $e', false);
//     }
//   }

//   void _showSnack(String message, bool success) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message, style: const TextStyle(color: Colors.white)),
//         backgroundColor:
//             success ? AppColors.button : Colors.redAccent.shade200,
//         behavior: SnackBarBehavior.floating,
//         margin: const EdgeInsets.all(16),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(14),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('My Pending Jobs')),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: _pendingJobsStream(),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return const Center(child: Text('Permission error.'));
//           }
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text('No pending jobs.'));
//           }

//           final docs = snapshot.data!.docs;
//           return ListView.builder(
//             padding: const EdgeInsets.all(12),
//             itemCount: docs.length,
//             itemBuilder: (context, index) {
//               final data = docs[index].data() as Map<String, dynamic>;
//               data['docId'] = docs[index].id;

//               final posterEmail = data['posterEmail'] ?? '';
//               final status = data['status'] ?? 'pending';

//               return Card(
//                 margin: const EdgeInsets.only(bottom: 12),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12)),
//                 elevation: 2,
//                 child: Padding(
//                   padding: const EdgeInsets.all(14),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(data['jobTitle'] ?? 'Unknown Job',
//                           style: const TextStyle(
//                               fontSize: 18, fontWeight: FontWeight.bold)),
//                       const SizedBox(height: 6),
//                       Text("Skill: ${data['skill'] ?? 'N/A'}"),
//                       const SizedBox(height: 4),
//                       Text("Location: ${data['location'] ?? 'N/A'}"),
//                       const SizedBox(height: 6),
//                       Text("Poster: $posterEmail",
//                           style:
//                               const TextStyle(fontWeight: FontWeight.w500)),
//                       const SizedBox(height: 12),

//                       // Chat button
//                       OutlinedButton.icon(
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => ChatPage(
//                                 receiverId: data['posterId'],
//                                 receiverEmail: posterEmail,
//                               ),
//                             ),
//                           );
//                         },
//                         icon: Icon(Icons.chat_bubble_outline,
//                             color: AppColors.button),
//                         label: Text("Chat",
//                             style: TextStyle(color: AppColors.button)),
//                         style: OutlinedButton.styleFrom(
//                           side: BorderSide(color: AppColors.button, width: 1.5),
//                           backgroundColor: Colors.white,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           minimumSize: const Size(double.infinity, 45),
//                         ),
//                       ),
//                       const SizedBox(height: 10),

//                       if (status == 'pending') ...[
//                         Row(
//                           children: [
//                             Expanded(
//                               child: ElevatedButton(
//                                 onPressed: () => _confirmJob(data),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: AppColors.button,
//                                   foregroundColor: Colors.white,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                 ),
//                                 child: const Text('Confirm Job'),
//                               ),
//                             ),
//                             const SizedBox(width: 10),
//                             Expanded(
//                               child: OutlinedButton(
//                                 onPressed: () => _rejectJob(data),
//                                 style: OutlinedButton.styleFrom(
//                                   side:
//                                       const BorderSide(color: Colors.red, width: 1.5),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                 ),
//                                 child: const Text('Reject',
//                                     style: TextStyle(color: Colors.red)),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         const Text(
//                           "Waiting for employer acceptance...",
//                           style: TextStyle(
//                               color: Colors.grey, fontStyle: FontStyle.italic),
//                         ),
//                       ]
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }








import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shohozkaz/core/constants.dart';
import 'package:shohozkaz/features/screen/pages/chatscreen/chat_page.dart';

class UserPendingJobsScreen extends StatefulWidget {
  const UserPendingJobsScreen({super.key});

  @override
  State<UserPendingJobsScreen> createState() => _UserPendingJobsScreenState();
}

class _UserPendingJobsScreenState extends State<UserPendingJobsScreen> {
  final String currentUid = FirebaseAuth.instance.currentUser!.uid;

  Stream<QuerySnapshot> _pendingJobsStream() {
    return FirebaseFirestore.instance
        .collection('pendingJobs')
        .where('applicantId', isEqualTo: currentUid)
        .snapshots();
  }

  Future<void> _updateNoteAndConfirm(Map<String, dynamic> data) async {
    final noteController = TextEditingController(text: data['note'] ?? '');

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Update Note Before Confirm'),
          content: TextField(
            controller: noteController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Enter your note (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.button,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await FirebaseFirestore.instance
                      .collection('pendingJobs')
                      .doc(data['docId'])
                      .update({
                    'note': noteController.text.trim(),
                    'status': 'confirmed',
                    'confirmedAt': FieldValue.serverTimestamp(),
                  });
                  _showSnack('Job confirmed. Waiting for employer acceptance.', true);
                } catch (e) {
                  _showSnack('Error confirming job: $e', false);
                }
              },
              child: const Text('Confirm Job'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _rejectJob(Map<String, dynamic> data) async {
    final confirm = await _showConfirmDialog(
        title: "Reject Job",
        message: "Are you sure you want to reject this job?");
    if (!confirm) return;

    try {
      await FirebaseFirestore.instance.collection('rejectJobs').doc().set({
        ...data,
        'status': 'rejected',
        'reason': 'Rejected by applicant',
        'rejectedAt': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection('pendingJobs')
          .doc(data['docId'])
          .delete();

      _showSnack('Job rejected successfully.', true);
    } catch (e) {
      _showSnack('Error rejecting job: $e', false);
    }
  }

  Future<void> _confirmToReject(Map<String, dynamic> data) async {
    final confirm = await _showConfirmDialog(
        title: "Reject Confirmed Job",
        message:
            "Are you sure you want to reject this job after confirming? This action cannot be undone.");
    if (!confirm) return;

    final reasonController = TextEditingController();
    await showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Reject Confirmed Job'),
          content: TextField(
            controller: reasonController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Enter reason for rejection (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await FirebaseFirestore.instance.collection('rejectJobs').doc().set({
                    ...data,
                    'status': 'rejected',
                    'reason': reasonController.text.trim().isEmpty
                        ? 'Rejected after confirmation'
                        : reasonController.text.trim(),
                    'rejectedAt': FieldValue.serverTimestamp(),
                  });

                  await FirebaseFirestore.instance
                      .collection('pendingJobs')
                      .doc(data['docId'])
                      .delete();

                  _showSnack('Job rejected after confirmation.', true);
                } catch (e) {
                  _showSnack('Error rejecting job: $e', false);
                }
              },
              child: const Text('Reject Job'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _showConfirmDialog(
      {required String title, required String message}) async {
    bool confirmed = false;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                confirmed = false;
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
                confirmed = true;
              },
              child: const Text('Yes, Reject'),
            ),
          ],
        );
      },
    );
    return confirmed;
  }

  void _showSnack(String message, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor:
            success ? AppColors.button : Colors.redAccent.shade200,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = theme.scaffoldBackgroundColor;
    final cardColor = theme.cardColor;
    final textColor = theme.colorScheme.onSurface;
    final noteBackground =
        isDark ? Colors.grey.shade900 : Colors.orange.shade50;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('My Pending Jobs'),
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _pendingJobsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Permission error.', style: TextStyle(color: textColor)));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text('No pending jobs.',
                    style: TextStyle(color: textColor.withOpacity(0.7))));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              data['docId'] = docs[index].id;

              final posterEmail = data['posterEmail'] ?? '';
              final note = (data['note'] != null &&
                      data['note'].toString().trim().isNotEmpty)
                  ? data['note']
                  : 'No note provided.';
              final status = data['status'] ?? 'pending';

              return Card(
                color: cardColor,
                elevation: 3,
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['jobTitle'] ?? 'Unknown Job',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor)),
                      const SizedBox(height: 6),
                      Text("Skill: ${data['skill'] ?? 'N/A'}",
                          style: TextStyle(color: textColor.withOpacity(0.8))),
                      const SizedBox(height: 4),
                      Text("Location: ${data['location'] ?? 'N/A'}",
                          style: TextStyle(color: textColor.withOpacity(0.8))),
                      const SizedBox(height: 6),
                      Text("Poster: $posterEmail",
                          style: TextStyle(
                              color: textColor, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 10),

                      // Note section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: noteBackground,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.button.withOpacity(0.5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Your Note:",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: textColor)),
                            const SizedBox(height: 4),
                            Text(note,
                                style: TextStyle(
                                    fontSize: 14,
                                    height: 1.4,
                                    color: textColor.withOpacity(0.8))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Chat button
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatPage(
                                receiverId: data['posterId'],
                                receiverEmail: posterEmail,
                              ),
                            ),
                          );
                        },
                        icon: Icon(Icons.chat_bubble_outline,
                            color: AppColors.button),
                        label: Text("Chat",
                            style: TextStyle(color: AppColors.button)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.button, width: 1.5),
                          backgroundColor: cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(double.infinity, 45),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Buttons
                      if (status == 'pending') ...[
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _updateNoteAndConfirm(data),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.button,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  minimumSize:
                                      const Size(double.infinity, 45),
                                ),
                                child: const Text('Confirm Job'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _rejectJob(data),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: Colors.red, width: 1.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  minimumSize:
                                      const Size(double.infinity, 45),
                                ),
                                child: const Text('Reject',
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text("Waiting for employer acceptance...",
                            style: TextStyle(
                                color: textColor.withOpacity(0.6),
                                fontStyle: FontStyle.italic)),
                      ] else if (status == 'confirmed') ...[
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _confirmToReject(data),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: Colors.red, width: 1.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Reject Confirmed Job',
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "You’ve confirmed this job. Waiting for employer action.",
                          style: TextStyle(
                            color: textColor.withOpacity(0.6),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
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
