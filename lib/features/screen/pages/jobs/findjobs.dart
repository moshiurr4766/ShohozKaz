

// // Working Code
// import 'package:flutter/material.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// //import 'package:iconsax/iconsax.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:shohozkaz/core/constants.dart';
// import 'job_details_screen.dart';

// class FindJobsScreen extends StatefulWidget {
//   const FindJobsScreen({super.key});

//   @override
//   State<FindJobsScreen> createState() => _FindJobsScreenState();
// }

// class _FindJobsScreenState extends State<FindJobsScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   String query = '';

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     const double spacing = 14;
//     final currentUserId = FirebaseAuth.instance.currentUser?.uid;

//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: Padding(
//           padding: const EdgeInsets.only(left: 16),
//           child: Text(
//             'Find Local Jobs',
//             style: TextStyle(
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//               color: Theme.of(context).colorScheme.onSurface,
//             ),
//           ),
//         ),
//         toolbarHeight: 60,
//         // actions: [
//         //   InkWell(
//         //     onTap: () {},
//         //     child: const Padding(
//         //       padding: EdgeInsets.symmetric(horizontal: 16),
//         //       child: Icon(Iconsax.notification),
//         //     ),
//         //   ),
//         // ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(spacing),
//         child: Column(
//           children: [
//             // SEARCH BAR
//             Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _searchController,
//                     decoration: InputDecoration(
//                       hintText: 'Search by skill, location or title',
//                       hintStyle: TextStyle(
//                         color: Theme.of(context).brightness == Brightness.dark
//                             ? Colors.grey[400]
//                             : Colors.grey[600],
//                       ),
//                       prefixIcon: Icon(
//                         Icons.search_outlined,
//                         color: Theme.of(context).brightness == Brightness.dark
//                             ? Colors.orange.shade300
//                             : Colors.orange,
//                         size: 20,
//                       ),
//                       filled: true,
//                       fillColor: Theme.of(context).brightness == Brightness.dark
//                           ? const Color(0xFF1E1E1E)
//                           : const Color(0xFFF6F2FF),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(14),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                     style: TextStyle(
//                       color: Theme.of(context).colorScheme.onSurface,
//                     ),
//                     onChanged: (value) {
//                       setState(() {
//                         query = value.trim().toLowerCase();
//                       });
//                     },
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: spacing),

//             // JOB LIST
//             Expanded(
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: FirebaseFirestore.instance
//                     .collection('jobs')
//                     .orderBy('postedAt', descending: true)
//                     .snapshots(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//                   if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                     return const Center(child: Text("No jobs found."));
//                   }

//                   final jobs = snapshot.data!.docs;

//                   // FILTER JOBS
//                   final filtered = jobs.where((doc) {
//                     final data = doc.data() as Map<String, dynamic>;
//                     final posterId = data['employerId'] ?? data['posterId'];

//                     if (posterId == currentUserId) {
//                       return false; // exclude own jobs
//                     }
//                     if (query.isEmpty) return true;

//                     return data.values.any(
//                       (value) => value.toString().toLowerCase().contains(query),
//                     );
//                   }).toList();

//                   if (filtered.isEmpty) {
//                     return const Center(
//                       child: Text("No jobs available right now."),
//                     );
//                   }

//                   return MasonryGridView.count(
//                     crossAxisCount: 2,
//                     mainAxisSpacing: spacing,
//                     crossAxisSpacing: spacing,
//                     itemCount: filtered.length,
//                     itemBuilder: (context, index) {
//                       final job =
//                           filtered[index].data() as Map<String, dynamic>;
//                       return _buildJobCard(job);
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   //JOB CARD WITH RATING + SAFE NULL HANDLING
//   Widget _buildJobCard(Map<String, dynamic> job) {
//     final String jobId = job['jobId']?.toString() ?? "";

//     // prevent crash if jobId is missing
//     if (jobId.isEmpty) return const SizedBox();

//     return FutureBuilder<QuerySnapshot>(
//       future: FirebaseFirestore.instance
//           .collection('jobFeedback')
//           .where('jobId', isEqualTo: jobId)
//           .get(),
//       builder: (context, snapshot) {
//         int totalFeedback = 0;
//         double avgRating = 0;

//         if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
//           totalFeedback = snapshot.data!.docs.length;

//           double total = 0;
//           for (var doc in snapshot.data!.docs) {
//             total += (doc['rating'] ?? 0).toDouble();
//           }

//           avgRating = total / totalFeedback;
//         }

//         return Card(
//           elevation: 1,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // IMAGE
//               Container(
//                 height: 80,
//                 decoration: BoxDecoration(
//                   borderRadius: const BorderRadius.vertical(
//                     top: Radius.circular(12),
//                   ),
//                   color: Colors.grey[300],
//                   image:
//                       (job['imageUrl'] != null &&
//                           job['imageUrl'].toString().isNotEmpty)
//                       ? DecorationImage(
//                           image: NetworkImage(job['imageUrl']),
//                           fit: BoxFit.cover,
//                         )
//                       : null,
//                 ),
//               ),

//               Padding(
//                 padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       job['title']?.toString() ?? '',
//                       style: const TextStyle(
//                         fontSize: 13,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),

//                     Text(
//                       job['skill']?.toString() ?? '',
//                       style: const TextStyle(fontSize: 12,color: AppColors.button,),
//                     ),
//                     Text(
//                       job['location']?.toString() ?? '',
//                       style: const TextStyle(fontSize: 10),
//                     ),

//                     const SizedBox(height: 2),
//                     Text(
//                       "৳ ${job['salary']?.toString() ?? ''}",
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 12,
//                         color: AppColors.button,
//                       ),
//                     ),

//                     const SizedBox(height: 6),

//                     //  FIXED HEIGHT RATING ROW
//                     SizedBox(
//                       height: 20,
//                       child: Row(
//                         children: [
//                           Icon(
//                             Icons.star,
//                             size: 16,
//                             color:
//                                 totalFeedback > 0 ? Colors.orange : Colors.grey,
//                           ),

//                           Text(
//                             totalFeedback == 0
//                                 ? "No ratings"
//                                 : avgRating.toStringAsFixed(1),
//                             style: const TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),

//                           if (totalFeedback > 0)
//                             Text(
//                               " ($totalFeedback reviews)",
//                               style: const TextStyle(fontSize: 11),
//                             ),
//                         ],
//                       ),
//                     ),

                   
//                     // if (totalFeedback > 0)
//                     //   SizedBox(
//                     //     height: 20,
//                     //     child: Row(
//                     //       children: [
//                     //         const Icon(
//                     //           Icons.star,
//                     //           size: 16,
//                     //           color: Colors.orange,
//                     //         ),

//                     //         const SizedBox(width: 4),

//                     //         Text(
//                     //           avgRating.toStringAsFixed(1),
//                     //           style: const TextStyle(
//                     //             fontSize: 12,
//                     //             fontWeight: FontWeight.bold,
//                     //           ),
//                     //         ),

//                     //         Text(
//                     //           " ($totalFeedback reviews)",
//                     //           style: const TextStyle(fontSize: 11),
//                     //         ),
//                     //       ],
//                     //     ),
//                     //   )
//                     // else
//                     //   const SizedBox(), // hide completely

//                     const SizedBox(height: 6),

//                     Row(
//                       children: [
//                         Expanded(
//                           child: Text(
//                             job['jobType']?.toString() ?? '',
//                             style: const TextStyle(
//                               fontSize: 12,
//                               color: Colors.grey,
//                             ),
//                           ),
//                         ),
//                         TextButton(
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => JobDetailsScreen(job: job),
//                               ),
//                             );
//                           },
//                           child: const Text(
//                             'View',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 13,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }











import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shohozkaz/core/constants.dart';
import 'job_details_screen.dart';

class FindJobsScreen extends StatefulWidget {
  const FindJobsScreen({super.key});

  @override
  State<FindJobsScreen> createState() => _FindJobsScreenState();
}

class _FindJobsScreenState extends State<FindJobsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double spacing = 14;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Text(
            'Find Local Services',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        toolbarHeight: 60,
      ),
      body: Padding(
        padding: const EdgeInsets.all(spacing),
        child: Column(
          children: [
            // SEARCH BAR
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by title, skill or location',
                      prefixIcon: Icon(
                        Icons.search_outlined,
                        color: Colors.orange,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1E1E1E)
                          : const Color(0xFFF6F2FF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        query = value.trim().toLowerCase();
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: spacing),

            // JOB LIST
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('jobs')
                    .orderBy('postedAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No jobs found."));
                  }

                  final jobs = snapshot.data!.docs;

                  // SEARCH FILTER (title, skill, location)
                  final filtered = jobs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final posterId = data['employerId'] ?? data['posterId'];

                    if (posterId == currentUserId) return false;
                    if (query.isEmpty) return true;

                    final q = query.toLowerCase();

                    //  TITLE 
                    final title =
                        (data['title'] ?? '').toString().toLowerCase();
                    final titleMatch = title.contains(q);

                    //  SKILL 
                    final skill =
                        (data['skill'] ?? '').toString().toLowerCase();
                    final skillMatch = skill.contains(q);

                    // LOCATION (smart partial match)
                    final location =
                        (data['location'] ?? '').toString().toLowerCase();

                    // Example: "Chakaria, Cox's Bazar, Chattogram, Bangladesh"
                    final locationParts = location
                        .split(',')
                        .map((e) => e.trim())
                        .toList();

                    final locationMatch = locationParts.any(
                      (part) => part.contains(q),
                    );

                    return titleMatch || skillMatch || locationMatch;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text("No matching jobs found."),
                    );
                  }

                  return MasonryGridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: spacing,
                    crossAxisSpacing: spacing,
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final job = filtered[index].data()
                          as Map<String, dynamic>;
                      return _buildJobCard(job);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // JOB CARD WITH RATING + SAFE NULL HANDLING
  Widget _buildJobCard(Map<String, dynamic> job) {
    final String jobId = job['jobId']?.toString() ?? "";
    if (jobId.isEmpty) return const SizedBox();

    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('jobFeedback')
          .where('jobId', isEqualTo: jobId)
          .get(),
      builder: (context, snapshot) {
        int totalFeedback = 0;
        double avgRating = 0;

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          totalFeedback = snapshot.data!.docs.length;

          double total = 0;
          for (var doc in snapshot.data!.docs) {
            total += (doc['rating'] ?? 0).toDouble();
          }

          avgRating = total / totalFeedback;
        }

        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IMAGE
              Container(
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  color: Colors.grey[300],
                  image: (job['imageUrl'] != null &&
                          job['imageUrl'].toString().isNotEmpty)
                      ? DecorationImage(
                          image: NetworkImage(job['imageUrl']),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job['title']?.toString() ?? '',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      job['skill']?.toString() ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.button,
                      ),
                    ),
                    Text(
                      job['location']?.toString() ?? '',
                      style: const TextStyle(fontSize: 10),
                    ),

                    const SizedBox(height: 2),
                    Text(
                      "৳ ${job['salary']?.toString() ?? ''}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppColors.button,
                      ),
                    ),

                    const SizedBox(height: 6),

                    SizedBox(
                      height: 20,
                      child: Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: totalFeedback > 0
                                ? Colors.orange
                                : Colors.grey,
                          ),
                          Text(
                            totalFeedback == 0
                                ? "No ratings"
                                : avgRating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (totalFeedback > 0)
                            Text(
                              " ($totalFeedback reviews)",
                              style: const TextStyle(fontSize: 11),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            job['jobType']?.toString() ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    JobDetailsScreen(job: job),
                              ),
                            );
                          },
                          child: const Text(
                            'View',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
