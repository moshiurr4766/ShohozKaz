import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shohozkaz/core/constants.dart';

class JobViewScreen extends StatelessWidget {
  final Map<String, dynamic> job;

  const JobViewScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 🔹 Format Firestore timestamp
    String postedDate = '';
    if (job['postedAt'] != null) {
      try {
        final date = job['postedAt'].toDate();
        postedDate = DateFormat('MMM dd, yyyy • hh:mm a').format(date);
      } catch (e) {
        postedDate = job['postedAt'].toString();
      }
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Job View',
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
              child: (job['imageUrl'] != null &&
                      job['imageUrl'].toString().isNotEmpty)
                  ? Image.network(
                      job['imageUrl'],
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _imageFallback("Image Not Found"),
                    )
                  : _imageFallback("No Image Available"),
            ),
            const SizedBox(height: 20),

            // 🔹 Title
            Text(
              job['title'] ?? '',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // 🔹 Location
            Row(
              children: [
                const Icon(Icons.location_on, size: 18, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  job['location'] ?? '',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 🔹 Salary
            Text(
              "৳ ${job['salary'] ?? ''}",
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
            if (job['summary'] != null &&
                job['summary'].toString().isNotEmpty)
              _sectionCard(
                title: "Summary",
                content: job['summary'],
                icon: Icons.notes,
                theme: theme,
              ),

            // 🔹 Description
            _sectionCard(
              title: "Job Description",
              content: job['description'] ?? '',
              icon: Icons.description_outlined,
              theme: theme,
            ),

            // 🔹 Requirements
            _sectionCard(
              title: "Requirements",
              content:
                  "Skill: ${job['skill'] ?? 'Not specified'}\nExperience: ${job['experience'] ?? 'Not specified'}\nEducation: ${job['education'] ?? 'Not specified'}",
              icon: Icons.build_circle_outlined,
              theme: theme,
            ),
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

  // 🔸 Fallback Image
  Widget _imageFallback(String text) {
    return Container(
      height: 220,
      width: double.infinity,
      color: Colors.grey[300],
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(color: Colors.black54),
      ),
    );
  }
}
