import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shohozkaz/features/screen/pages/jobs/updatejobs/jobview.dart';
import 'package:shohozkaz/features/screen/pages/jobs/updatejobs/jobedit.dart';

class UpdateJobsScreen extends StatefulWidget {
  const UpdateJobsScreen({super.key});

  @override
  State<UpdateJobsScreen> createState() => _UpdateJobsScreenState();
}

class _UpdateJobsScreenState extends State<UpdateJobsScreen> {
  final user = FirebaseAuth.instance.currentUser;

  // 🗑 Delete job with confirmation
  Future<void> _confirmDelete(String jobId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Job'),
        content: const Text('Are you sure you want to delete this job?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('jobs').doc(jobId).delete();
      if (mounted) {
        final theme = Theme.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(' Job Delete successfully!',
            style: TextStyle(color: Colors.white),),
            backgroundColor: theme.colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        );
      }
    }
  }

  void _viewJob(Map<String, dynamic> job) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => JobViewScreen(job: job)),
    );
  }

  void _editJob(BuildContext context, String jobId, Map<String, dynamic> job) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditJobScreen(jobId: jobId, jobData: job),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Please log in first")));
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("My Posted Jobs"),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('jobs')
            .where('employerId', isEqualTo: user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No jobs found."));
          }

          final jobs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index].data() as Map<String, dynamic>;
              final jobId = jobs[index].id;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: isDark ? 1 : 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: isDark
                    ? const Color(0xFF1E1E1E)
                    : theme.cardColor.withOpacity(0.95),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      // Job Image / Icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.orange.withOpacity(0.2)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child:
                            (job['imageUrl'] != null &&
                                job['imageUrl'].toString().isNotEmpty)
                            ? Image.network(
                                job['imageUrl'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.work_rounded,
                                      color: Colors.orange,
                                      size: 26,
                                    ),
                              )
                            : const Icon(
                                Icons.work_rounded,
                                color: Colors.orange,
                                size: 26,
                              ),
                      ),
                      const SizedBox(width: 14),

                      // Job Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job['title'] ?? 'Untitled Job',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.grey[500],
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    job['location'] ?? 'Unknown Location',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 13,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              job['salary'] ?? '',
                              style: const TextStyle(
                                color: Colors.deepOrange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Popup menu
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'view') {
                            _viewJob(job);
                          } else if (value == 'edit') {
                            _editJob(context, jobId, job);
                          } else if (value == 'delete') {
                            _confirmDelete(jobId);
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'view', child: Text('View')),
                          PopupMenuItem(value: 'edit', child: Text('Edit')),
                          PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      ),
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
