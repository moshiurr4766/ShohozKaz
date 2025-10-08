

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shohozkaz/core/constants.dart';
import 'package:shohozkaz/features/screen/pages/chatscreen/chat_page.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 🔹 Format Firestore timestamp
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
            // 🔹 Job Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: (widget.job['imageUrl'] != null &&
                      widget.job['imageUrl'].toString().isNotEmpty)
                  ? Image.network(
                      widget.job['imageUrl'],
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          _imageFallback("Image Not Found"),
                    )
                  : _imageFallback("No Image Available"),
            ),
            const SizedBox(height: 20),

            // 🔹 Title
            Text(
              widget.job['title'] ?? '',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // 🔹 Location
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

            // 🔹 Salary
            Text(
              "৳ ${widget.job['salary'] ?? ''}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.button,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),

            // 🔹 Posted Date
            if (postedDate.isNotEmpty)
              Text(
                "Posted on $postedDate",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),

            const Divider(height: 32, thickness: 0.8),

            // 🔹 Summary
            if (widget.job['summary'] != null &&
                widget.job['summary'].toString().isNotEmpty)
              _sectionCard(
                title: "Summary",
                content: widget.job['summary'],
                icon: Icons.notes,
                theme: theme,
              ),

            // 🔹 Description
            _sectionCard(
              title: "Job Description",
              content: widget.job['description'] ?? '',
              icon: Icons.description_outlined,
              theme: theme,
            ),

            // 🔹 Requirements
            _sectionCard(
              title: "Requirements",
              content:
                  "Skill: ${widget.job['skill'] ?? 'Not specified'}\nExperience: ${widget.job['experience'] ?? 'Not specified'}\nEducation: ${widget.job['education'] ?? 'Not specified'}",
              icon: Icons.build_circle_outlined,
              theme: theme,
            ),

            const SizedBox(height: 25),

            // 🔹 Live Chat
            _liveChatSection(context, theme),

            const SizedBox(height: 25),

            // 🔹 Action Buttons
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
                    onPressed: () {},
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text("Apply Now"),
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

  // 🔸 Section Card
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

  // 🔸 Live Chat Section
  Widget _liveChatSection(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(18),
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
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(1, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Live Communication",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            "Have questions about this job? Chat directly with the employer.",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text("Chat with Employer"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.button,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              final employerId = widget.job['employerId'] ?? '';
              final employerEmail = widget.job['employerEmail'] ?? '';
              

              if (employerId.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      receiverEmail: employerEmail,
                      receiverId: employerId,
                      
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Employer information not available."),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // Fallback Image
  Widget _imageFallback(String text) {
    return Container(
      height: 220,
      width: double.infinity,
      color: Colors.grey[300],
      alignment: Alignment.center,
      child: Text(text, style: const TextStyle(color: Colors.black54)),
    );
  }

  // Save Job Function
  Future<void> _saveJob(BuildContext context) async {
    setState(() => _isSaving = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please log in to save jobs.")),
        );
        return;
      }

      final jobId = widget.job['id'] ?? widget.job['docId'] ?? '';
      final savedJobRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('savedJobs')
          .doc(jobId.isNotEmpty ? jobId : DateTime.now().millisecondsSinceEpoch.toString());

      await savedJobRef.set(widget.job);

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Job saved successfully!"),
          backgroundColor: AppColors.button,
        ),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save job: $e")),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
