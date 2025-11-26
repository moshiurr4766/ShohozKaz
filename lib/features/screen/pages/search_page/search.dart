import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shohozkaz/features/screen/pages/jobs/job_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String query = "";

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final currentUser = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor:
          brightness == Brightness.dark ? const Color(0xFF0F0F0F) : Colors.grey[100],
      appBar: _buildSearchBar(context),
      body: query.isEmpty
          ? Center(
              child: Text(
                "Search Results Will Appear Here",
                style: TextStyle(
                  fontSize: 16,
                  color: brightness == Brightness.dark
                      ? Colors.grey[300]
                      : Colors.grey[800],
                ),
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('jobs')
                  .orderBy('postedAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final jobs = snapshot.data!.docs;

                // FILTER
                List<Map<String, dynamic>> filtered = jobs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final posterId = data['employerId'] ?? data['posterId'];
                  if (posterId == currentUser) return false;

                  return data.values.any((value) =>
                      value.toString().toLowerCase().contains(query));
                }).map((e) => e.data() as Map<String, dynamic>).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      "No matching jobs found.",
                      style: TextStyle(
                          fontSize: 16,
                          color: brightness == Brightness.dark
                              ? Colors.grey[300]
                              : Colors.grey[800]),
                    ),
                  );
                }

                return FutureBuilder(
                  future: _sortJobsByRating(filtered),
                  builder: (context, ratingSnap) {
                    if (!ratingSnap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final sortedJobs =
                        ratingSnap.data as List<Map<String, dynamic>>;

                    return ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: sortedJobs.length,
                      itemBuilder: (context, index) {
                        return _buildJobTile(context, sortedJobs[index]);
                      },
                    );
                  },
                );
              },
            ),
    );
  }

  // --------------------------- SEARCH BAR --------------------------- //

  AppBar _buildSearchBar(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return AppBar(
      backgroundColor:
          brightness == Brightness.dark ? const Color(0xFF1A1A1A) : Colors.white,
      elevation: 1,
      iconTheme: IconThemeData(
        color: brightness == Brightness.dark ? Colors.white : Colors.black,
      ),
      title: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: brightness == Brightness.dark
              ? const Color(0xFF2B2B2B)
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _searchController,
          autofocus: true,
          style: TextStyle(
            color: brightness == Brightness.dark
                ? Colors.white
                : Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: "Search in ShohozKaz",
            hintStyle: TextStyle(
              color: brightness == Brightness.dark
                  ? Colors.grey[400]
                  : Colors.grey[600],
            ),
            prefixIcon: Icon(Iconsax.search_normal,
                size: 20,
                color: brightness == Brightness.dark
                    ? Colors.orange.shade300
                    : Colors.orange),
            border: InputBorder.none,
          ),
          onChanged: (val) {
            setState(() {
              query = val.trim().toLowerCase();
            });
          },
        ),
      ),
    );
  }

  // --------------------------- SORT BY RATING --------------------------- //

  Future<List<Map<String, dynamic>>> _sortJobsByRating(
      List<Map<String, dynamic>> jobs) async {
    for (var job in jobs) {
      final jobId = job['jobId'] ?? "";

      final feedbackSnap = await FirebaseFirestore.instance
          .collection('jobFeedback')
          .where('jobId', isEqualTo: jobId)
          .get();

      if (feedbackSnap.docs.isEmpty) {
        job['avgRating'] = 0.0;
      } else {
        double total = 0;
        for (var doc in feedbackSnap.docs) {
          total += (doc['rating'] ?? 0).toDouble();
        }
        job['avgRating'] = total / feedbackSnap.docs.length;
      }
    }

    // Sort: HIGH → LOW
    jobs.sort((a, b) => b['avgRating'].compareTo(a['avgRating']));
    return jobs;
  }

  // --------------------------- JOB TILE --------------------------- //

  Widget _buildJobTile(BuildContext context, Map<String, dynamic> job) {
    final rating = job['avgRating'] ?? 0.0;
    final brightness = Theme.of(context).brightness;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => JobDetailsScreen(job: job),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        color: brightness == Brightness.dark
            ? const Color(0xFF1A1A1A)
            : Colors.white,
        shadowColor: brightness == Brightness.dark
            ? Colors.black.withOpacity(0.3)
            : Colors.grey.withOpacity(0.2),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IMAGE
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 60,
                  width: 60,
                  color: brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.grey[300],
                  child: job['imageUrl'] != null &&
                          job['imageUrl'].toString().isNotEmpty
                      ? Image.network(job['imageUrl'], fit: BoxFit.cover)
                      : Icon(Icons.work,
                          size: 28,
                          color: brightness == Brightness.dark
                              ? Colors.grey[400]
                              : Colors.grey),
                ),
              ),

              const SizedBox(width: 12),

              // TEXT DETAILS
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job['title'] ?? '',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black)),

                    Text(job['location'] ?? '',
                        style: TextStyle(
                            fontSize: 12,
                            color: brightness == Brightness.dark
                                ? Colors.grey[400]
                                : Colors.grey[700])),

                    const SizedBox(height: 4),

                    Text("৳ ${job['salary']}",
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green)),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Icon(Icons.star,
                            size: 16,
                            color: rating > 0
                                ? Colors.orange
                                : Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          rating == 0
                              ? "No ratings"
                              : rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
