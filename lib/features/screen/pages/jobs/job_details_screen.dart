

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:shohozkaz/core/constants.dart';
// import 'package:shohozkaz/features/screen/pages/chatscreen/chat_page.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class JobDetailsScreen extends StatefulWidget {
//   final Map<String, dynamic> job;

//   const JobDetailsScreen({super.key, required this.job});

//   @override
//   State<JobDetailsScreen> createState() => _JobDetailsScreenState();
// }

// class _JobDetailsScreenState extends State<JobDetailsScreen> {
//   bool _isSaving = false;
//   bool _isApplying = false;
//   final TextEditingController _noteController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     String postedDate = '';
//     if (widget.job['postedAt'] != null) {
//       try {
//         final date = widget.job['postedAt'].toDate();
//         postedDate = DateFormat('MMM dd, yyyy • hh:mm a').format(date);
//       } catch (e) {
//         postedDate = widget.job['postedAt'].toString();
//       }
//     }

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       appBar: AppBar(
//         title: const Text(
//           'Job Details',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         backgroundColor: theme.colorScheme.surface,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(16),
//               child: (widget.job['imageUrl'] != null &&
//                       widget.job['imageUrl'].toString().isNotEmpty)
//                   ? Image.network(
//                       widget.job['imageUrl'],
//                       height: 220,
//                       width: double.infinity,
//                       fit: BoxFit.cover,
//                       errorBuilder: (_, __, ___) =>
//                           _imageFallback("Image Not Found"),
//                     )
//                   : _imageFallback("No Image Available"),
//             ),
//             const SizedBox(height: 20),

//             Text(
//               widget.job['title'] ?? '',
//               style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),

//             Row(
//               children: [
//                 const Icon(Icons.location_on, size: 18, color: Colors.grey),
//                 const SizedBox(width: 4),
//                 Text(
//                   widget.job['location'] ?? '',
//                   style: const TextStyle(color: Colors.grey),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),

//             Text(
//               "৳ ${widget.job['salary'] ?? ''}",
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.button,
//                 fontSize: 16,
//               ),
//             ),
//             const SizedBox(height: 6),

//             if (postedDate.isNotEmpty)
//               Text(
//                 "Posted on $postedDate",
//                 style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
//               ),

//             const Divider(height: 32, thickness: 0.8),

//             if (widget.job['summary'] != null &&
//                 widget.job['summary'].toString().isNotEmpty)
//               _sectionCard(
//                 title: "Summary",
//                 content: widget.job['summary'],
//                 icon: Icons.notes,
//                 theme: theme,
//               ),

//             _sectionCard(
//               title: "Job Description",
//               content: widget.job['description'] ?? '',
//               icon: Icons.description_outlined,
//               theme: theme,
//             ),

//             _sectionCard(
//               title: "Requirements",
//               content:
//                   "Skill: ${widget.job['skill'] ?? 'Not specified'}\nExperience: ${widget.job['experience'] ?? 'Not specified'}\nEducation: ${widget.job['education'] ?? 'Not specified'}",
//               icon: Icons.build_circle_outlined,
//               theme: theme,
//             ),

//             const SizedBox(height: 25),

//             _liveChatSection(context, theme),
//             const SizedBox(height: 20),
//             _noteResourceSection(theme),
//             const SizedBox(height: 25),

//             Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton.icon(
//                     onPressed: _isSaving ? null : () => _saveJob(context),
//                     icon: _isSaving
//                         ? const SizedBox(
//                             height: 16,
//                             width: 16,
//                             child: CircularProgressIndicator(strokeWidth: 2),
//                           )
//                         : const Icon(Icons.bookmark_border),
//                     label: const Text("Save Job"),
//                     style: OutlinedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       side: BorderSide(color: theme.colorScheme.primary),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: _isApplying ? null : () => _applyForJob(context),
//                     icon: _isApplying
//                         ? const SizedBox(
//                             height: 16,
//                             width: 16,
//                             child: CircularProgressIndicator(
//                                 strokeWidth: 2, color: Colors.white),
//                           )
//                         : const Icon(Icons.check_circle_outline),
//                     label: const Text("Apply Now"),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.button,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   //  UPDATED apply method (flat structure)
//   Future<void> _applyForJob(BuildContext context) async {
//     setState(() => _isApplying = true);
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Please log in to apply for jobs.")),
//         );
//         setState(() => _isApplying = false);
//         return;
//       }

//       final jobId = widget.job['jobId'] ?? widget.job['id'] ?? '';
//       if (jobId.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Invalid job ID.")),
//         );
//         setState(() => _isApplying = false);
//         return;
//       }

//       final docRef = FirebaseFirestore.instance.collection('pendingJobs').doc();

//       final applicantData = {
//         "jobId": jobId,
//         "posterId": widget.job['employerId'],
//         "posterEmail": widget.job['employerEmail'],
//         "applicantId": user.uid,
//         "applicantEmail": user.email,
//         "jobTitle": widget.job['title'],
//         "location": widget.job['location'],
//         "salary": widget.job['salary'],
//         "jobType": widget.job['jobType'],
//         "skill": widget.job['skill'],
//         "experience": widget.job['experience'],
//         "education": widget.job['education'],
//         "status": "pending",
//         "note": _noteController.text.trim(),
//         "appliedAt": FieldValue.serverTimestamp(),
//       };

//       await docRef.set(applicantData);

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Application submitted successfully.")),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Failed to apply: $e")),
//       );
//     } finally {
//       if (mounted) setState(() => _isApplying = false);
//     }
//   }

//   Widget _sectionCard({
//     required String title,
//     required String content,
//     required IconData icon,
//     required ThemeData theme,
//   }) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 18),
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: theme.brightness == Brightness.dark
//             ? Colors.grey.shade900
//             : Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: theme.brightness == Brightness.dark
//               ? Colors.grey.shade800
//               : Colors.grey.shade300,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(icon, color: AppColors.button),
//               const SizedBox(width: 6),
//               Text(title,
//                   style: const TextStyle(
//                       fontSize: 16, fontWeight: FontWeight.bold)),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Text(content, style: const TextStyle(fontSize: 15, height: 1.4)),
//         ],
//       ),
//     );
//   }

//   Widget _liveChatSection(BuildContext context, ThemeData theme) {
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: theme.brightness == Brightness.dark
//             ? Colors.grey.shade900
//             : Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: theme.brightness == Brightness.dark
//               ? Colors.grey.shade800
//               : Colors.grey.shade300,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             "Live Communication",
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 10),
//           const Text(
//             "Have questions about this job? Chat directly with the employer.",
//             style: TextStyle(color: Colors.grey),
//           ),
//           const SizedBox(height: 16),
//           ElevatedButton.icon(
//             icon: const Icon(Icons.chat_bubble_outline),
//             label: const Text("Chat with Employer"),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.button,
//               foregroundColor: Colors.white,
//               minimumSize: const Size(double.infinity, 50),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             onPressed: () {
//               final employerId = widget.job['employerId'] ?? '';
//               final employerEmail = widget.job['employerEmail'] ?? '';

//               if (employerId.isNotEmpty) {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => ChatPage(
//                       receiverEmail: employerEmail,
//                       receiverId: employerId,
//                     ),
//                   ),
//                 );
//               } else {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text("Employer information not available."),
//                   ),
//                 );
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _noteResourceSection(ThemeData theme) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: theme.brightness == Brightness.dark
//             ? Colors.grey.shade900
//             : Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: theme.brightness == Brightness.dark
//               ? Colors.grey.shade800
//               : Colors.grey.shade300,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: const [
//               Icon(Icons.note_alt_outlined, color: AppColors.button),
//               SizedBox(width: 6),
//               Text(
//                 "Your Notes / Resources",
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//           const Text(
//             "You can save any additional notes or resource links related to this job for later reference.",
//             style: TextStyle(color: Colors.grey, fontSize: 13),
//           ),
//           const SizedBox(height: 12),
//           TextField(
//             controller: _noteController,
//             maxLines: 3,
//             decoration: InputDecoration(
//               hintText: "Write a note or paste a link here...",
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               contentPadding:
//                   const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _imageFallback(String text) {
//     return Container(
//       height: 220,
//       width: double.infinity,
//       color: Colors.grey[300],
//       alignment: Alignment.center,
//       child: Text(text, style: const TextStyle(color: Colors.black54)),
//     );
//   }

//   Future<void> _saveJob(BuildContext context) async {
//     setState(() => _isSaving = true);
//     final theme = Theme.of(context);
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) {
//         if (mounted) setState(() => _isSaving = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Please log in to save jobs.")),
//         );
//         return;
//       }

//       final jobId = widget.job['id'] ?? widget.job['docId'] ?? '';
//       final savedJobRef = FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .collection('savedJobs')
//           .doc(jobId.isNotEmpty
//               ? jobId
//               : DateTime.now().millisecondsSinceEpoch.toString());

//       await savedJobRef.set(widget.job);

//       // ignore: use_build_context_synchronously
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text('Job saved successfully!'),
//           backgroundColor: theme.colorScheme.primary,
//         ),
//       );
//     } catch (e) {
//       // ignore: use_build_context_synchronously
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to save job: $e')),
//       );
//     } finally {
//       if (mounted) setState(() => _isSaving = false);
//     }
//   }
// }




































// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:shohozkaz/core/constants.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class JobDetailsScreen extends StatefulWidget {
//   final Map<String, dynamic> job;

//   const JobDetailsScreen({super.key, required this.job});

//   @override
//   State<JobDetailsScreen> createState() => _JobDetailsScreenState();
// }

// class _JobDetailsScreenState extends State<JobDetailsScreen> {
//   bool _isSaving = false;
//   bool _isApplying = false;
//   final TextEditingController _noteController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     String postedDate = '';
//     if (widget.job['postedAt'] != null) {
//       try {
//         final date = widget.job['postedAt'].toDate();
//         postedDate = DateFormat('MMM dd, yyyy • hh:mm a').format(date);
//       } catch (e) {
//         postedDate = widget.job['postedAt'].toString();
//       }
//     }

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       appBar: AppBar(
//         title: const Text(
//           'Job Details',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         backgroundColor: theme.colorScheme.surface,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(16),
//               child: (widget.job['imageUrl'] != null &&
//                       widget.job['imageUrl'].toString().isNotEmpty)
//                   ? Image.network(
//                       widget.job['imageUrl'],
//                       height: 220,
//                       width: double.infinity,
//                       fit: BoxFit.cover,
//                       errorBuilder: (_, __, ___) =>
//                           _imageFallback("Image Not Found"),
//                     )
//                   : _imageFallback("No Image Available"),
//             ),
//             const SizedBox(height: 20),

//             Text(
//               widget.job['title'] ?? '',
//               style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),

//             Row(
//               children: [
//                 const Icon(Icons.location_on, size: 18, color: Colors.grey),
//                 const SizedBox(width: 4),
//                 Text(
//                   widget.job['location'] ?? '',
//                   style: const TextStyle(color: Colors.grey),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),

//             Text(
//               "৳ ${widget.job['salary'] ?? ''}",
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.button,
//                 fontSize: 16,
//               ),
//             ),
//             const SizedBox(height: 6),

//             if (postedDate.isNotEmpty)
//               Text(
//                 "Posted on $postedDate",
//                 style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
//               ),

//             const Divider(height: 32, thickness: 0.8),

//             if (widget.job['summary'] != null &&
//                 widget.job['summary'].toString().isNotEmpty)
//               _sectionCard(
//                 title: "Summary",
//                 content: widget.job['summary'],
//                 icon: Icons.notes,
//                 theme: theme,
//               ),

//             _sectionCard(
//               title: "Job Description",
//               content: widget.job['description'] ?? '',
//               icon: Icons.description_outlined,
//               theme: theme,
//             ),

//             _sectionCard(
//               title: "Requirements",
//               content:
//                   "Skill: ${widget.job['skill'] ?? 'Not specified'}\nExperience: ${widget.job['experience'] ?? 'Not specified'}\nEducation: ${widget.job['education'] ?? 'Not specified'}",
//               icon: Icons.build_circle_outlined,
//               theme: theme,
//             ),

//             const SizedBox(height: 25),

//             _noteResourceSection(theme),
//             const SizedBox(height: 25),

//             Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton.icon(
//                     onPressed: _isSaving ? null : () => _saveJob(context),
//                     icon: _isSaving
//                         ? const SizedBox(
//                             height: 16,
//                             width: 16,
//                             child: CircularProgressIndicator(strokeWidth: 2),
//                           )
//                         : const Icon(Icons.bookmark_border),
//                     label: const Text("Save Job"),
//                     style: OutlinedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       side: BorderSide(color: theme.colorScheme.primary),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed:
//                         _isApplying ? null : () => _confirmRequestJob(context),
//                     icon: _isApplying
//                         ? const SizedBox(
//                             height: 16,
//                             width: 16,
//                             child: CircularProgressIndicator(
//                                 strokeWidth: 2, color: Colors.white),
//                           )
//                         : const Icon(Icons.work_outline),
//                     label: const Text("Request Job"),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.button,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _confirmRequestJob(BuildContext context) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Confirm Request"),
//         content: const Text("Do you want to request this job?"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text("Cancel"),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context, true),
//             style: ElevatedButton.styleFrom(backgroundColor: AppColors.button),
//             child: const Text("Confirm",
//               style: TextStyle(color: Colors.white),),
//           ),
//         ],
//       ),
//     );

//     if (confirm == true) {
//       await _requestJob(context);
//     }
//   }

//   Future<void> _requestJob(BuildContext context) async {
//     setState(() => _isApplying = true);
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) {
//         _showSnack(context, "Please log in to request a job.", false);
//         setState(() => _isApplying = false);
//         return;
//       }

//       final jobId = widget.job['jobId'] ?? widget.job['id'] ?? '';
//       if (jobId.isEmpty) {
//         _showSnack(context, "Invalid job ID.", false);
//         setState(() => _isApplying = false);
//         return;
//       }

//       // Unique jobOrderId
//       final jobOrderId =
//           FirebaseFirestore.instance.collection('pendingJobs').doc().id;

//       final requestData = {
//         "jobOrderId": jobOrderId,
//         "jobId": jobId,
//         "posterId": widget.job['employerId'],
//         "posterEmail": widget.job['employerEmail'],
//         "applicantId": user.uid,
//         "applicantEmail": user.email,
//         "jobTitle": widget.job['title'],
//         "location": widget.job['location'],
//         "salary": widget.job['salary'],
//         "jobType": widget.job['jobType'],
//         "skill": widget.job['skill'],
//         "experience": widget.job['experience'],
//         "education": widget.job['education'],
//         "status": "pending",
//         "note": _noteController.text.trim(),
//         "requestedAt": FieldValue.serverTimestamp(),
//       };

//       await FirebaseFirestore.instance
//           .collection('pendingJobs')
//           .doc(jobOrderId)
//           .set(requestData);

//       _showSnack(context, "Job request submitted successfully.", true);
//     } catch (e) {
//       _showSnack(context, "Job request failed! $e", false);
//     } finally {
//       if (mounted) setState(() => _isApplying = false);
//     }
//   }

//   void _showSnack(BuildContext context, String message, bool success) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           message,
//           style: const TextStyle(color: Colors.white),
//         ),
//         backgroundColor:
//             success ? AppColors.button : Theme.of(context).colorScheme.primary,
//         behavior: SnackBarBehavior.floating,
//         margin: const EdgeInsets.all(16),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(14),
//         ),
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//       ),
//     );
//   }

//   Widget _sectionCard({
//     required String title,
//     required String content,
//     required IconData icon,
//     required ThemeData theme,
//   }) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 18),
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: theme.brightness == Brightness.dark
//             ? Colors.grey.shade900
//             : Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: theme.brightness == Brightness.dark
//               ? Colors.grey.shade800
//               : Colors.grey.shade300,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(icon, color: AppColors.button),
//               const SizedBox(width: 6),
//               Text(title,
//                   style: const TextStyle(
//                       fontSize: 16, fontWeight: FontWeight.bold)),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Text(content, style: const TextStyle(fontSize: 15, height: 1.4)),
//         ],
//       ),
//     );
//   }

//   Widget _noteResourceSection(ThemeData theme) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: theme.brightness == Brightness.dark
//             ? Colors.grey.shade900
//             : Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: theme.brightness == Brightness.dark
//               ? Colors.grey.shade800
//               : Colors.grey.shade300,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: const [
//               Icon(Icons.note_alt_outlined, color: AppColors.button),
//               SizedBox(width: 6),
//               Text(
//                 "Your Notes / Resources",
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//           const Text(
//             "You can save any additional notes or resource links related to this job for later reference.",
//             style: TextStyle(color: Colors.grey, fontSize: 13),
//           ),
//           const SizedBox(height: 12),
//           TextField(
//             controller: _noteController,
//             maxLines: 3,
//             decoration: InputDecoration(
//               hintText: "Write a note or paste a link here...",
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               contentPadding:
//                   const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _imageFallback(String text) {
//     return Container(
//       height: 220,
//       width: double.infinity,
//       color: Colors.grey[300],
//       alignment: Alignment.center,
//       child: Text(text, style: const TextStyle(color: Colors.black54)),
//     );
//   }

//   Future<void> _saveJob(BuildContext context) async {
//     setState(() => _isSaving = true);
//     //final theme = Theme.of(context);
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) {
//         _showSnack(context, "Please log in to save jobs.", false);
//         setState(() => _isSaving = false);
//         return;
//       }

//       final jobId = widget.job['id'] ?? widget.job['docId'] ?? '';
//       final savedJobRef = FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .collection('savedJobs')
//           .doc(jobId.isNotEmpty
//               ? jobId
//               : DateTime.now().millisecondsSinceEpoch.toString());

//       await savedJobRef.set(widget.job);
//       _showSnack(context, "Job saved successfully!", true);
//     } catch (e) {
//       _showSnack(context, "Failed to save job: $e", false);
//     } finally {
//       if (mounted) setState(() => _isSaving = false);
//     }
//   }
// }



























import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shohozkaz/core/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JobDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> job;

  const JobDetailsScreen({super.key, required this.job});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  bool _isSaving = false;
  bool _isApplying = false;
  final TextEditingController _noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String postedDate = '';
    if (widget.job['postedAt'] != null) {
      try {
        final date = widget.job['postedAt'].toDate();
        postedDate = DateFormat('MMM dd, yyyy • hh:mm a').format(date);
      } catch (e) {
        postedDate = widget.job['postedAt'].toString();
      }
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Job Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: (widget.job['imageUrl'] != null &&
                      widget.job['imageUrl'].toString().isNotEmpty)
                  ? Image.network(
                      widget.job['imageUrl'],
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _imageFallback("Image Not Found"),
                    )
                  : _imageFallback("No Image Available"),
            ),
            const SizedBox(height: 20),

            Text(
              widget.job['title'] ?? '',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.location_on, size: 18, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  widget.job['location'] ?? '',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Text(
              "৳ ${widget.job['salary'] ?? ''}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.button,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),

            if (postedDate.isNotEmpty)
              Text(
                "Posted on $postedDate",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),

            const Divider(height: 32, thickness: 0.8),

            if (widget.job['summary'] != null &&
                widget.job['summary'].toString().isNotEmpty)
              _sectionCard(
                title: "Summary",
                content: widget.job['summary'],
                icon: Icons.notes,
                theme: theme,
              ),

            _sectionCard(
              title: "Job Description",
              content: widget.job['description'] ?? '',
              icon: Icons.description_outlined,
              theme: theme,
            ),

            _sectionCard(
              title: "Requirements",
              content:
                  "Skill: ${widget.job['skill'] ?? 'Not specified'}\nExperience: ${widget.job['experience'] ?? 'Not specified'}\nEducation: ${widget.job['education'] ?? 'Not specified'}",
              icon: Icons.build_circle_outlined,
              theme: theme,
            ),

            const SizedBox(height: 25),

            _noteResourceSection(theme),
            const SizedBox(height: 25),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isSaving ? null : () => _saveJob(context),
                    icon: _isSaving
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.bookmark_border),
                    label: const Text("Save Job"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: theme.colorScheme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        _isApplying ? null : () => _confirmRequestJob(context),
                    icon: _isApplying
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.work_outline),
                    label: const Text("Request Job"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.button,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmRequestJob(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Request"),
        content: const Text("Do you want to request this job?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.button),
            child: const Text("Confirm",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _requestJob(context);
    }
  }

  // ==============================
  // Prevent duplicate job requests
  // ==============================
  Future<void> _requestJob(BuildContext context) async {
    setState(() => _isApplying = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showSnack(context, "Please log in to request a job.", false);
        setState(() => _isApplying = false);
        return;
      }

      final jobId = widget.job['jobId'] ?? widget.job['id'] ?? '';
      if (jobId.isEmpty) {
        _showSnack(context, "Invalid job ID.", false);
        setState(() => _isApplying = false);
        return;
      }

      // 🔹 Check if already requested (pending)
      final existing = await FirebaseFirestore.instance
          .collection('pendingJobs')
          .where('jobId', isEqualTo: jobId)
          .where('applicantId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        _showSnack(context, "You have already requested this job.", false);
        setState(() => _isApplying = false);
        return;
      }

      // 🔹 Create new job request
      final jobOrderId =
          FirebaseFirestore.instance.collection('pendingJobs').doc().id;

      final requestData = {
        "jobOrderId": jobOrderId,
        "jobId": jobId,
        "posterId": widget.job['employerId'],
        "posterEmail": widget.job['employerEmail'],
        "applicantId": user.uid,
        "applicantEmail": user.email,
        "jobTitle": widget.job['title'],
        "location": widget.job['location'],
        "salary": widget.job['salary'],
        "jobType": widget.job['jobType'],
        "skill": widget.job['skill'],
        "experience": widget.job['experience'],
        "education": widget.job['education'],
        "status": "pending",
        "note": _noteController.text.trim(),
        "requestedAt": FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('pendingJobs')
          .doc(jobOrderId)
          .set(requestData);

      _showSnack(context, "Job request submitted successfully.", true);
    } catch (e) {
      _showSnack(context, "Job request failed! $e", false);
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }

  void _showSnack(BuildContext context, String message, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor:
            success ? AppColors.button : Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required String content,
    required IconData icon,
    required ThemeData theme,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? Colors.grey.shade900
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? Colors.grey.shade800
              : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.button),
              const SizedBox(width: 6),
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 15, height: 1.4)),
        ],
      ),
    );
  }

  Widget _noteResourceSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? Colors.grey.shade900
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? Colors.grey.shade800
              : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.note_alt_outlined, color: AppColors.button),
              SizedBox(width: 6),
              Text(
                "Your Notes / Resources",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "You can save any additional notes or resource links related to this job for later reference.",
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Write a note or paste a link here...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageFallback(String text) {
    return Container(
      height: 220,
      width: double.infinity,
      color: Colors.grey[300],
      alignment: Alignment.center,
      child: Text(text, style: const TextStyle(color: Colors.black54)),
    );
  }

  Future<void> _saveJob(BuildContext context) async {
    setState(() => _isSaving = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showSnack(context, "Please log in to save jobs.", false);
        setState(() => _isSaving = false);
        return;
      }

      final jobId = widget.job['id'] ?? widget.job['docId'] ?? '';
      final savedJobRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('savedJobs')
          .doc(jobId.isNotEmpty
              ? jobId
              : DateTime.now().millisecondsSinceEpoch.toString());

      await savedJobRef.set(widget.job);
      _showSnack(context, "Job saved successfully!", true);
    } catch (e) {
      _showSnack(context, "Failed to save job: $e", false);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
