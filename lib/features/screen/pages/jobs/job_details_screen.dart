import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting postedAt
import 'package:shohozkaz/core/constants.dart';

class JobDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> job;
  const JobDetailsScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    // Format date if postedAt exists
    String postedDate = '';
    if (job['postedAt'] != null) {
      try {
        // Firestore Timestamp → DateTime
        final date = job['postedAt'].toDate();
        postedDate = DateFormat('MMM dd, yyyy • hh:mm a').format(date);
      } catch (e) {
        postedDate = job['postedAt'].toString();
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(job['title'] ?? 'Job Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Image with safe fallback
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: (job['imageUrl'] != null &&
                      job['imageUrl'].toString().isNotEmpty)
                  ? Image.network(
                      job['imageUrl'],
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.grey[300],
                          alignment: Alignment.center,
                          child: const Text(
                            "Image Not Found",
                            style: TextStyle(color: Colors.black54),
                          ),
                        );
                      },
                    )
                  : Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[300],
                      alignment: Alignment.center,
                      child: const Text(
                        "No Image Available",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
            ),

            const SizedBox(height: 16),

            // ✅ Title
            Text(
              job['title'] ?? '',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),
            Text(
              job['location'] ?? '',
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 6),
            Text(
              "৳ ${job['salary'] ?? ''}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.button,
              ),
            ),

            const SizedBox(height: 6),
            if (postedDate.isNotEmpty)
              Text(
                "Posted on $postedDate",
                style: const TextStyle(color: Colors.grey),
              ),

            const Divider(height: 30),

            // ✅ Summary
            if (job['summary'] != null && job['summary'].toString().isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Summary",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(job['summary']),
                  const SizedBox(height: 20),
                ],
              ),

            // ✅ Description
            const Text(
              "Job Description",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(job['description'] ?? ''),

            const SizedBox(height: 20),

            // ✅ Skills & Qualifications
            const Text(
              "Requirements",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text("Skill: ${job['skill'] ?? ''}"),
            Text("Experience: ${job['experience'] ?? ''}"),
            Text("Education: ${job['education'] ?? ''}"),

            const SizedBox(height: 40),

            // ✅ Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      
                    },
                    child: const Text("Save Job"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.button,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Apply Now"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
