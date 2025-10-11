



// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:shohozkaz/core/constants.dart';

// class PendingJobsScreen extends StatefulWidget {
//   const PendingJobsScreen({super.key});

//   @override
//   State<PendingJobsScreen> createState() => _PendingJobsScreenState();
// }

// class _PendingJobsScreenState extends State<PendingJobsScreen> {
//   late final String currentUid;

//   @override
//   void initState() {
//     super.initState();
//     currentUid = FirebaseAuth.instance.currentUser!.uid;
//   }

//   Stream<QuerySnapshot> _pendingJobsStream() {
//     return FirebaseFirestore.instance
//         .collection('pendingJobs')
//         .where(Filter.or(
//           Filter('posterId', isEqualTo: currentUid),
//           Filter('applicantId', isEqualTo: currentUid),
//         ))
//         .snapshots();
//   }

//   //  Accept applicant → move to openJobs
//   Future<void> _acceptApplicant(Map<String, dynamic> data) async {
//     try {
//       final currentUser = FirebaseAuth.instance.currentUser;
//       if (currentUser == null) return;

//       final docRef = FirebaseFirestore.instance.collection('openJobs').doc();
//       await docRef.set({
//         ...data,
//         'posterId': data['posterId'] ?? currentUser.uid,
//         'posterEmail': data['posterEmail'] ?? currentUser.email,
//         'status': 'open',
//         'acceptedAt': FieldValue.serverTimestamp(),
//       });

//       await FirebaseFirestore.instance
//           .collection('pendingJobs')
//           .doc(data['docId'])
//           .delete();

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Applicant accepted.')),
//       );
//     } catch (e) {
//       debugPrint('Error accepting applicant: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error accepting applicant: $e')),
//       );
//     }
//   }

//   // Reject applicant → move to canceledJobs
//   Future<void> _rejectApplicant(Map<String, dynamic> data) async {
//     try {
//       final currentUser = FirebaseAuth.instance.currentUser;
//       if (currentUser == null) return;

//       final docRef = FirebaseFirestore.instance.collection('canceledJobs').doc();
//       await docRef.set({
//         ...data,
//         'posterId': data['posterId'] ?? currentUser.uid,
//         'posterEmail': data['posterEmail'] ?? currentUser.email,
//         'status': 'canceled',
//         'reason': 'Rejected by poster',
//         'canceledAt': FieldValue.serverTimestamp(),
//       });

//       await FirebaseFirestore.instance
//           .collection('pendingJobs')
//           .doc(data['docId'])
//           .delete();

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Applicant rejected.')),
//       );
//     } catch (e) {
//       debugPrint('Error rejecting applicant: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error rejecting applicant: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Pending Applications')),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: _pendingJobsStream(),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return const Center(
//                 child: Text('Permission denied or query error.'));
//           }
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text('No pending applications.'));
//           }

//           final docs = snapshot.data!.docs;

//           return ListView.builder(
//             padding: const EdgeInsets.all(12),
//             itemCount: docs.length,
//             itemBuilder: (context, index) {
//               final data = docs[index].data() as Map<String, dynamic>;
//               data['docId'] = docs[index].id;
//               final isPoster = data['posterId'] == currentUid;

//               return Card(
//                 margin: const EdgeInsets.only(bottom: 12),
//                 child: Padding(
//                   padding: const EdgeInsets.all(14),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(data['jobTitle'] ?? 'Unknown Job',
//                           style: const TextStyle(
//                               fontSize: 18, fontWeight: FontWeight.bold)),
//                       const SizedBox(height: 6),
//                       Text("Applicant: ${data['applicantEmail'] ?? 'N/A'}"),
//                       const SizedBox(height: 6),
//                       Text("Location: ${data['location'] ?? ''}"),
//                       const SizedBox(height: 12),
//                       if (isPoster)
//                         Row(
//                           children: [
//                             Expanded(
//                               child: ElevatedButton(
//                                 onPressed: () => _acceptApplicant(data),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: AppColors.button,
//                                   foregroundColor: Colors.white,
//                                 ),
//                                 child: const Text('Accept'),
//                               ),
//                             ),
//                             const SizedBox(width: 10),
//                             Expanded(
//                               child: OutlinedButton(
//                                 onPressed: () => _rejectApplicant(data),
//                                 style: OutlinedButton.styleFrom(
//                                   side: const BorderSide(color: Colors.red),
//                                 ),
//                                 child: const Text('Reject',
//                                     style: TextStyle(color: Colors.red)),
//                               ),
//                             )
//                           ],
//                         )
//                       else
//                         const Text(
//                           'Waiting for employer response...',
//                           style: TextStyle(
//                             color: Colors.grey,
//                             fontStyle: FontStyle.italic,
//                           ),
//                         ),
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

































// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:shohozkaz/core/constants.dart';
// import 'package:shohozkaz/features/screen/pages/chatscreen/chat_page.dart';

// class PendingJobsScreen extends StatefulWidget {
//   const PendingJobsScreen({super.key});

//   @override
//   State<PendingJobsScreen> createState() => _PendingJobsScreenState();
// }

// class _PendingJobsScreenState extends State<PendingJobsScreen> {
//   late final String currentUid;

//   @override
//   void initState() {
//     super.initState();
//     currentUid = FirebaseAuth.instance.currentUser!.uid;
//   }

//   Stream<QuerySnapshot> _pendingJobsStream() {
//     return FirebaseFirestore.instance
//         .collection('pendingJobs')
//         .where(Filter.or(
//           Filter('posterId', isEqualTo: currentUid),
//           Filter('applicantId', isEqualTo: currentUid),
//         ))
//         .snapshots();
//   }

//   // ============ ACCEPT by poster ============
//   Future<void> _acceptApplicant(Map<String, dynamic> data) async {
//     try {
//       final docRef = FirebaseFirestore.instance.collection('openJobs').doc();
//       await docRef.set({
//         ...data,
//         'status': 'open',
//         'acceptedAt': FieldValue.serverTimestamp(),
//       });

//       await FirebaseFirestore.instance
//           .collection('pendingJobs')
//           .doc(data['docId'])
//           .delete();

//       _showSnack('Job moved to open jobs.', true);
//     } catch (e) {
//       _showSnack('Error accepting applicant: $e', false);
//     }
//   }

//   // ============ REJECT (both sides) ============
//   Future<void> _rejectJob(Map<String, dynamic> data, String by) async {
//     try {
//       await FirebaseFirestore.instance.collection('canceledJobs').doc().set({
//         ...data,
//         'status': 'canceled',
//         'reason': 'Rejected by $by',
//         'canceledAt': FieldValue.serverTimestamp(),
//       });

//       await FirebaseFirestore.instance
//           .collection('pendingJobs')
//           .doc(data['docId'])
//           .delete();

//       _showSnack('Job request rejected by $by.', true);
//     } catch (e) {
//       _showSnack('Error rejecting: $e', false);
//     }
//   }

//   // ============ CONFIRM by user ============
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
//       appBar: AppBar(title: const Text('Pending Jobs')),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: _pendingJobsStream(),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return const Center(
//                 child: Text('Permission denied or query error.'));
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

//               final bool isPoster = data['posterId'] == currentUid;
//               final bool isUser = data['applicantId'] == currentUid;

//               final String posterEmail = data['posterEmail'] ?? '';
//               final String applicantEmail = data['applicantEmail'] ?? '';
//               final String status = data['status'] ?? 'pending';

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
//                       Text(
//                         isPoster
//                             ? "Applicant: $applicantEmail"
//                             : "Poster: $posterEmail",
//                         style:
//                             const TextStyle(fontWeight: FontWeight.w500),
//                       ),
//                       const SizedBox(height: 12),

//                       // Live chat
//                       ElevatedButton.icon(
//                         onPressed: () {
//                           final receiverId =
//                               isPoster ? data['applicantId'] : data['posterId'];
//                           final receiverEmail = isPoster
//                               ? data['applicantEmail']
//                               : data['posterEmail'];

//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => ChatPage(
//                                 receiverId: receiverId,
//                                 receiverEmail: receiverEmail,
//                               ),
//                             ),
//                           );
//                         },
//                         icon: const Icon(Icons.chat_bubble_outline),
//                         label: const Text("Chat"),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppColors.button,
//                           foregroundColor: Colors.white,
//                           minimumSize: const Size(double.infinity, 45),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 12),

//                       // Role-based actions
//                       if (isUser && status == 'pending')
//                         Row(
//                           children: [
//                             Expanded(
//                               child: ElevatedButton(
//                                 onPressed: () => _confirmJob(data),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.green,
//                                   foregroundColor: Colors.white,
//                                 ),
//                                 child: const Text('Confirm Job'),
//                               ),
//                             ),
//                             const SizedBox(width: 10),
//                             Expanded(
//                               child: OutlinedButton(
//                                 onPressed: () =>
//                                     _rejectJob(data, 'Applicant'),
//                                 style: OutlinedButton.styleFrom(
//                                   side:
//                                       const BorderSide(color: Colors.red),
//                                 ),
//                                 child: const Text('Reject',
//                                     style: TextStyle(color: Colors.red)),
//                               ),
//                             ),
//                           ],
//                         )
//                       else if (isPoster && status == 'confirmed')
//                         Row(
//                           children: [
//                             Expanded(
//                               child: ElevatedButton(
//                                 onPressed: () => _acceptApplicant(data),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: AppColors.button,
//                                   foregroundColor: Colors.white,
//                                 ),
//                                 child: const Text('Accept Job'),
//                               ),
//                             ),
//                             const SizedBox(width: 10),
//                             Expanded(
//                               child: OutlinedButton(
//                                 onPressed: () =>
//                                     _rejectJob(data, 'Poster'),
//                                 style: OutlinedButton.styleFrom(
//                                   side:
//                                       const BorderSide(color: Colors.red),
//                                 ),
//                                 child: const Text('Reject',
//                                     style: TextStyle(color: Colors.red)),
//                               ),
//                             )
//                           ],
//                         )
//                       else
//                         Padding(
//                           padding: const EdgeInsets.only(top: 6),
//                           child: Text(
//                             status == 'confirmed'
//                                 ? 'Waiting for employer to accept...'
//                                 : 'Waiting for applicant confirmation...',
//                             style: const TextStyle(
//                                 color: Colors.grey,
//                                 fontStyle: FontStyle.italic),
//                           ),
//                         ),
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
































// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:shohozkaz/core/constants.dart';
// import 'package:shohozkaz/features/screen/pages/chatscreen/chat_page.dart';

// class PendingJobsScreen extends StatefulWidget {
//   const PendingJobsScreen({super.key});

//   @override
//   State<PendingJobsScreen> createState() => _PendingJobsScreenState();
// }

// class _PendingJobsScreenState extends State<PendingJobsScreen> {
//   late final String currentUid;

//   @override
//   void initState() {
//     super.initState();
//     currentUid = FirebaseAuth.instance.currentUser!.uid;
//   }

//   Stream<QuerySnapshot> _pendingJobsStream() {
//     return FirebaseFirestore.instance
//         .collection('pendingJobs')
//         .where(Filter.or(
//           Filter('posterId', isEqualTo: currentUid),
//           Filter('applicantId', isEqualTo: currentUid),
//         ))
//         .snapshots();
//   }

//   // ============ ACCEPT by poster ============
//   Future<void> _acceptApplicant(Map<String, dynamic> data) async {
//     try {
//       final docRef = FirebaseFirestore.instance.collection('openJobs').doc();
//       await docRef.set({
//         ...data,
//         'status': 'open',
//         'acceptedAt': FieldValue.serverTimestamp(),
//       });

//       await FirebaseFirestore.instance
//           .collection('pendingJobs')
//           .doc(data['docId'])
//           .delete();

//       _showSnack('Job moved to open jobs.', true);
//     } catch (e) {
//       _showSnack('Error accepting applicant: $e', false);
//     }
//   }

//   // ============ REJECT (both sides) ============
//   Future<void> _rejectJob(Map<String, dynamic> data, String by) async {
//     try {
//       await FirebaseFirestore.instance.collection('rejectJobs').doc().set({
//         ...data,
//         'status': 'rejected',
//         'reason': 'Rejected by $by',
//         'rejectedAt': FieldValue.serverTimestamp(),
//       });

//       await FirebaseFirestore.instance
//           .collection('pendingJobs')
//           .doc(data['docId'])
//           .delete();

//       _showSnack('Job rejected by $by.', true);
//     } catch (e) {
//       _showSnack('Error rejecting: $e', false);
//     }
//   }

//   // ============ CONFIRM by user ============
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
//       appBar: AppBar(title: const Text('Pending Jobs')),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: _pendingJobsStream(),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return const Center(
//                 child: Text('Permission denied or query error.'));
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

//               final bool isPoster = data['posterId'] == currentUid;
//               final bool isUser = data['applicantId'] == currentUid;

//               final String posterEmail = data['posterEmail'] ?? '';
//               final String applicantEmail = data['applicantEmail'] ?? '';
//               final String status = data['status'] ?? 'pending';

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
//                       Text(
//                         isPoster
//                             ? "Applicant: $applicantEmail"
//                             : "Poster: $posterEmail",
//                         style:
//                             const TextStyle(fontWeight: FontWeight.w500),
//                       ),
//                       const SizedBox(height: 12),

//                       // Live Chat Button (white background + orange text)
//                       OutlinedButton.icon(
//                         onPressed: () {
//                           final receiverId =
//                               isPoster ? data['applicantId'] : data['posterId'];
//                           final receiverEmail = isPoster
//                               ? data['applicantEmail']
//                               : data['posterEmail'];

//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => ChatPage(
//                                 receiverId: receiverId,
//                                 receiverEmail: receiverEmail,
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
//                           minimumSize: const Size(double.infinity, 45),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 12),

//                       // Logic: role + status
//                       if (isUser && status == 'pending')
//                         Row(
//                           children: [
//                             Expanded(
//                               child: ElevatedButton(
//                                 onPressed: () => _confirmJob(data),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.green,
//                                   foregroundColor: Colors.white,
//                                 ),
//                                 child: const Text('Confirm Job'),
//                               ),
//                             ),
//                             const SizedBox(width: 10),
//                             Expanded(
//                               child: OutlinedButton(
//                                 onPressed: () =>
//                                     _rejectJob(data, 'Applicant'),
//                                 style: OutlinedButton.styleFrom(
//                                   side:
//                                       const BorderSide(color: Colors.red),
//                                 ),
//                                 child: const Text('Reject',
//                                     style: TextStyle(color: Colors.red)),
//                               ),
//                             ),
//                           ],
//                         )
//                       else if (isPoster && status == 'confirmed')
//                         Row(
//                           children: [
//                             Expanded(
//                               child: ElevatedButton(
//                                 onPressed: () => _acceptApplicant(data),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: AppColors.button,
//                                   foregroundColor: Colors.white,
//                                 ),
//                                 child: const Text('Accept Job'),
//                               ),
//                             ),
//                             const SizedBox(width: 10),
//                             Expanded(
//                               child: OutlinedButton(
//                                 onPressed: () =>
//                                     _rejectJob(data, 'Poster'),
//                                 style: OutlinedButton.styleFrom(
//                                   side:
//                                       const BorderSide(color: Colors.red),
//                                 ),
//                                 child: const Text('Reject',
//                                     style: TextStyle(color: Colors.red)),
//                               ),
//                             )
//                           ],
//                         )
//                       else
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.only(top: 6),
//                               child: Text(
//                                 status == 'confirmed'
//                                     ? 'Waiting for employer to accept...'
//                                     : 'Waiting for applicant confirmation...',
//                                 style: const TextStyle(
//                                     color: Colors.grey,
//                                     fontStyle: FontStyle.italic),
//                               ),
//                             ),
//                             if (isPoster && status == 'pending') ...[
//                               const SizedBox(height: 8),
//                               OutlinedButton(
//                                 onPressed: () =>
//                                     _rejectJob(data, 'Poster'),
//                                 style: OutlinedButton.styleFrom(
//                                   side:
//                                       const BorderSide(color: Colors.red),
//                                 ),
//                                 child: const Text('Reject',
//                                     style: TextStyle(color: Colors.red)),
//                               ),
//                             ],
//                           ],
//                         ),
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

class PendingJobsScreen extends StatefulWidget {
  const PendingJobsScreen({super.key});

  @override
  State<PendingJobsScreen> createState() => _PendingJobsScreenState();
}

class _PendingJobsScreenState extends State<PendingJobsScreen> {
  late final String currentUid;

  @override
  void initState() {
    super.initState();
    currentUid = FirebaseAuth.instance.currentUser!.uid;
  }

  Stream<QuerySnapshot> _pendingJobsStream() {
    return FirebaseFirestore.instance
        .collection('pendingJobs')
        .where(Filter.or(
          Filter('posterId', isEqualTo: currentUid),
          Filter('applicantId', isEqualTo: currentUid),
        ))
        .snapshots();
  }

  // ============ ACCEPT by poster ============
  Future<void> _acceptApplicant(Map<String, dynamic> data) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('openJobs').doc();
      await docRef.set({
        ...data,
        'status': 'open',
        'acceptedAt': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection('pendingJobs')
          .doc(data['docId'])
          .delete();

      _showSnack('Job moved to open jobs.', true);
    } catch (e) {
      _showSnack('Error accepting applicant: $e', false);
    }
  }

  // ============ REJECT (both sides) ============
  Future<void> _rejectJob(Map<String, dynamic> data, String by) async {
    try {
      await FirebaseFirestore.instance.collection('rejectJobs').doc().set({
        ...data,
        'status': 'rejected',
        'reason': 'Rejected by $by',
        'rejectedAt': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection('pendingJobs')
          .doc(data['docId'])
          .delete();

      _showSnack('Job rejected by $by.', true);
    } catch (e) {
      _showSnack('Error rejecting: $e', false);
    }
  }

  // ============ CONFIRM by user ============
  Future<void> _confirmJob(Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance
          .collection('pendingJobs')
          .doc(data['docId'])
          .update({
        'status': 'confirmed',
        'confirmedAt': FieldValue.serverTimestamp(),
      });
      _showSnack('Job confirmed. Waiting for employer acceptance.', true);
    } catch (e) {
      _showSnack('Error confirming job: $e', false);
    }
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
    return Scaffold(
      appBar: AppBar(title: const Text('Pending Jobs')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _pendingJobsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
                child: Text('Permission denied or query error.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No pending jobs.'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              data['docId'] = docs[index].id;

              final bool isPoster = data['posterId'] == currentUid;
              final bool isUser = data['applicantId'] == currentUid;

              final String posterEmail = data['posterEmail'] ?? '';
              final String applicantEmail = data['applicantEmail'] ?? '';
              final String status = data['status'] ?? 'pending';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['jobTitle'] ?? 'Unknown Job',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text("Skill: ${data['skill'] ?? 'N/A'}"),
                      const SizedBox(height: 4),
                      Text("Location: ${data['location'] ?? 'N/A'}"),
                      const SizedBox(height: 6),
                      Text(
                        isPoster
                            ? "Applicant: $applicantEmail"
                            : "Poster: $posterEmail",
                        style:
                            const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 12),

                      // Chat button (white background + orange border)
                      OutlinedButton.icon(
                        onPressed: () {
                          final receiverId =
                              isPoster ? data['applicantId'] : data['posterId'];
                          final receiverEmail = isPoster
                              ? data['applicantEmail']
                              : data['posterEmail'];

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatPage(
                                receiverId: receiverId,
                                receiverEmail: receiverEmail,
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
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(double.infinity, 45),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ===== Role + Status Buttons =====
                      if (isUser && status == 'pending') ...[
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _confirmJob(data),
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
                                onPressed: () => _rejectJob(data, 'Applicant'),
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
                        const Text(
                          "Waiting for employer acceptance...",
                          style: TextStyle(
                              color: Colors.grey, fontStyle: FontStyle.italic),
                        ),
                      ] else if (isPoster && status == 'confirmed') ...[
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _acceptApplicant(data),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.button,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  minimumSize:
                                      const Size(double.infinity, 45),
                                ),
                                child: const Text('Accept Job'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _rejectJob(data, 'Poster'),
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
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Job confirmed by applicant. Waiting for your action.",
                          style: TextStyle(
                              color: Colors.grey, fontStyle: FontStyle.italic),
                        ),
                      ] else if (isPoster && status == 'pending') ...[
                        // Poster waiting for applicant confirmation → only reject button full width
                        OutlinedButton(
                          onPressed: () => _rejectJob(data, 'Poster'),
                          style: OutlinedButton.styleFrom(
                            side:
                                const BorderSide(color: Colors.red, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            minimumSize: const Size(double.infinity, 45),
                          ),
                          child: const Text('Reject',
                              style: TextStyle(color: Colors.red)),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Waiting for applicant confirmation...",
                          style: TextStyle(
                              color: Colors.grey, fontStyle: FontStyle.italic),
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
