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
              child:
                  (widget.job['imageUrl'] != null &&
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

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("jobFeedback")
                  .where("jobId", isEqualTo: widget.job['jobId'])
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) return const SizedBox();

                double avg = 0;
                for (var d in docs) {
                  final r = (d['rating'] ?? 0);
                  if (r is num) avg += r.toDouble();
                }
                avg /= docs.length;

                return GestureDetector(
                  onTap: () => _showFeedbackSheet(context, docs),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        avg.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(" (${docs.length} reviews)"),
                    ],
                  ),
                );
              },
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
              title: "Worker Qualifications",
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
                    onPressed: _isApplying
                        ? null
                        : () => _confirmRequestJob(context),
                    icon: _isApplying
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
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
            child: const Text("Confirm", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _requestJob(context);
    }
  }

  // Prevent duplicate job requests

  // Future<void> _requestJob(BuildContext context) async {
  //   setState(() => _isApplying = true);
  //   try {
  //     final user = FirebaseAuth.instance.currentUser;
  //     if (user == null) {
  //       _showSnack(context, "Please log in to request a job.", false);
  //       setState(() => _isApplying = false);
  //       return;
  //     }

  //     final jobId = widget.job['jobId'] ?? widget.job['id'] ?? '';
  //     if (jobId.isEmpty) {
  //       _showSnack(context, "Invalid job ID.", false);
  //       setState(() => _isApplying = false);
  //       return;
  //     }

  //     // 🔹 Check if already requested (pending)
  //     final existing = await FirebaseFirestore.instance
  //         .collection('pendingJobs')
  //         .where('jobId', isEqualTo: jobId)
  //         .where('applicantId', isEqualTo: user.uid)
  //         .limit(1)
  //         .get();

  //     if (existing.docs.isNotEmpty) {
  //       _showSnack(context, "You have already requested this job.", false);
  //       setState(() => _isApplying = false);
  //       return;
  //     }

  //     // 🔹 Create new job request
  //     final jobOrderId = FirebaseFirestore.instance
  //         .collection('pendingJobs')
  //         .doc()
  //         .id;

  //     final requestData = {
  //       "jobOrderId": jobOrderId,
  //       "jobId": jobId,
  //       "posterId": widget.job['employerId'],
  //       "posterEmail": widget.job['employerEmail'],
  //       "applicantId": user.uid,
  //       "applicantEmail": user.email,
  //       "jobTitle": widget.job['title'],
  //       "location": widget.job['location'],
  //       "salary": widget.job['salary'],
  //       "jobType": widget.job['jobType'],
  //       "skill": widget.job['skill'],
  //       "experience": widget.job['experience'],
  //       "education": widget.job['education'],
  //       "status": "pending",
  //       "note": _noteController.text.trim(),
  //       "requestedAt": FieldValue.serverTimestamp(),
  //     };

  //     await FirebaseFirestore.instance
  //         .collection('pendingJobs')
  //         .doc(jobOrderId)
  //         .set(requestData);

  //     _showSnack(context, "Job request submitted successfully.", true);
  //   } catch (e) {
  //     _showSnack(context, "Job request failed! $e", false);
  //   } finally {
  //     if (mounted) setState(() => _isApplying = false);
  //   }
  // }

  Future<void> _requestJob(BuildContext context) async {
    setState(() => _isApplying = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        _showSnack(context, "Please log in to request a job.", false);
        setState(() => _isApplying = false);
        return;
      }

      //  CHECK USER STATUS FROM userInfo COLLECTION
      final userDoc = await FirebaseFirestore.instance
          .collection("userInfo")
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        _showSnack(context, "User information not found!", false);
        setState(() => _isApplying = false);
        return;
      }

      final status = userDoc['status'] ?? "inactive";

      if (status != "active") {
        _showSnack(
          context,
          "Your account is not active. You cannot request jobs.",
          false,
        );
        setState(() => _isApplying = false);
        return;
      }

      // CHECK IF JOB ALREADY REQUESTED
      final jobId = widget.job['jobId'] ?? widget.job['id'] ?? '';

      if (jobId.isEmpty) {
        _showSnack(context, "Invalid job ID.", false);
        setState(() => _isApplying = false);
        return;
      }

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

      // CREATE REQUEST IF USER IS ACTIVE
      final jobOrderId = FirebaseFirestore.instance
          .collection('pendingJobs')
          .doc()
          .id;

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
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: success
            ? AppColors.button
            : Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    );
  }

  // Rating Ui start
  void _showFeedbackSheet(
    BuildContext context,
    List<QueryDocumentSnapshot> docs,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: 40,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 16),

                // header
                Row(
                  children: [
                    SizedBox(height: 10),
                    Text(
                      "Ratings & Reviews",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    _avgRating(docs),
                  ],
                ),

                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (_, i) => _reviewCard(docs[i]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _avgRating(List<QueryDocumentSnapshot> docs) {
    double avg = 0;
    for (var d in docs) {
      final r = (d['rating'] ?? 0);
      if (r is num) avg += r.toDouble();
    }
    avg /= docs.length;

    return Row(
      children: [
        Text(
          avg.toStringAsFixed(1),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(width: 4),
        Icon(Icons.star, color: Colors.orange, size: 18),
      ],
    );
  }

  Widget _reviewCard(QueryDocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;

    final rating = (data['rating'] ?? 0).toDouble();
    final comment = data['feedback']?.toString() ?? "";
    final List images = (data['images'] ?? []);

    String date = "";
    if (data['createdAt'] is Timestamp) {
      date = DateFormat("d MMM yyyy").format(data['createdAt'].toDate());
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection("userInfo")
          .doc(data['givenBy'])
          .get(),
      builder: (context, snapshot) {
        String name = "User";
        String avatar = "";

        if (snapshot.hasData && snapshot.data!.exists) {
          name = snapshot.data!['name'] ?? "User";
          avatar = snapshot.data!['profileImage'] ?? "";
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[900]
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile row
              Row(
                children: [
                  // avatar
                  avatar.isNotEmpty
                      ? CircleAvatar(backgroundImage: NetworkImage(avatar))
                      : CircleAvatar(
                          backgroundColor: Colors.deepPurple,
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : "?",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                  const SizedBox(width: 10),

                  // name + date
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (date.isNotEmpty)
                        Text(
                          date,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),

                  const Spacer(),

                  // rating
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.orange.shade400, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              //  Feedback message section
              Text(
                comment.isNotEmpty ? comment : "No message provided",
                style: const TextStyle(fontSize: 13, height: 1.5),
              ),

              //  Images row
              if (images.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 80,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: images.length,
                    itemBuilder: (_, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        images[i],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  //End

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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
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
          .doc(
            jobId.isNotEmpty
                ? jobId
                : DateTime.now().millisecondsSinceEpoch.toString(),
          );

      await savedJobRef.set(widget.job);
      _showSnack(context, "Job saved successfully!", true);
    } catch (e) {
      _showSnack(context, "Failed to save job: $e", false);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
