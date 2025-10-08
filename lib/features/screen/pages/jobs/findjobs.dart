

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            'Find Local Jobs',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        toolbarHeight: 60,
        actions: [
          InkWell(
            onTap: () {},
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Icon(Iconsax.notification),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(spacing),
        child: Column(
          children: [
            // 🔍 Search bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by skill, location or title',
                      prefixIcon: const Icon(Icons.search_outlined,
                          color: AppColors.button, size: 20),
                      filled: true,
                      fillColor: const Color(0xFFF6F2FF),
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

            // 🔥 Jobs list
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

                  // ✅ Smooth live filtering
                  final filtered = jobs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    if (query.isEmpty) return true;
                    return data.values.any(
                      (value) =>
                          value.toString().toLowerCase().contains(query),
                    );
                  }).toList();

                  return MasonryGridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: spacing,
                    crossAxisSpacing: spacing,
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final job = filtered[index].data() as Map<String, dynamic>;
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

  Widget _buildJobCard(Map<String, dynamic> job) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                image: job['imageUrl'] != null && job['imageUrl'] != ''
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
                  Text(job['title'] ?? '',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          )),
                  const SizedBox(height: 2),
                  Text(job['location'] ?? '',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontSize: 13)),
                  const SizedBox(height: 2),
                  Text("৳ ${job['salary'] ?? ''}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.button)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          job['jobType'] ?? '',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => JobDetailsScreen(job: job),
                            ),
                          );
                        },
                        child: const Text('View',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}













// import 'package:flutter/material.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
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

//     return Scaffold(
//       appBar: AppBar(
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
//         actions: [
//           InkWell(
//             onTap: () {},
//             child: const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16),
//               child: Icon(Iconsax.notification),
//             ),
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(spacing),
//         child: Column(
//           children: [
//             // 🔍 Search bar
//             Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _searchController,
//                     decoration: InputDecoration(
//                       hintText: 'Search by skill, location or title',
//                       prefixIcon: const Icon(
//                         Icons.search_outlined,
//                         color: AppColors.button,
//                         size: 20,
//                       ),
//                       filled: true,
//                       fillColor: Theme.of(context).brightness == Brightness.dark
//                           ? Colors.grey[850]
//                           : const Color(0xFFF6F2FF),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(14),
//                         borderSide: BorderSide.none,
//                       ),
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

//             // 🔥 Jobs list
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

//                   // ✅ Smooth live filtering
//                   final filtered = jobs.where((doc) {
//                     final data = doc.data() as Map<String, dynamic>;
//                     if (query.isEmpty) return true;
//                     return data.values.any(
//                       (value) =>
//                           value.toString().toLowerCase().contains(query),
//                     );
//                   }).toList();

//                   return MasonryGridView.count(
//                     crossAxisCount: 2,
//                     mainAxisSpacing: spacing,
//                     crossAxisSpacing: spacing,
//                     itemCount: filtered.length,
//                     itemBuilder: (context, index) {
//                       final job = filtered[index].data() as Map<String, dynamic>;
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

//   Widget _buildJobCard(Map<String, dynamic> job) {
//     return Card(
//       elevation: 1,
//       color: Theme.of(context).cardColor,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//       child: Padding(
//         padding: const EdgeInsets.only(bottom: 6),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               height: 80,
//               decoration: BoxDecoration(
//                 color: Theme.of(context).brightness == Brightness.dark
//                     ? Colors.grey[800]
//                     : Colors.grey[300],
//                 borderRadius:
//                     const BorderRadius.vertical(top: Radius.circular(12)),
//                 image: job['imageUrl'] != null && job['imageUrl'] != ''
//                     ? DecorationImage(
//                         image: NetworkImage(job['imageUrl']),
//                         fit: BoxFit.cover,
//                       )
//                     : null,
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(job['title'] ?? '',
//                       style: Theme.of(context).textTheme.titleSmall?.copyWith(
//                             fontSize: 13,
//                             fontWeight: FontWeight.bold,
//                           )),
//                   const SizedBox(height: 2),
//                   Text(job['location'] ?? '',
//                       style: Theme.of(context)
//                           .textTheme
//                           .bodySmall
//                           ?.copyWith(fontSize: 13)),
//                   const SizedBox(height: 2),
//                   Text("৳ ${job['salary'] ?? ''}",
//                       style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 13,
//                           color: AppColors.button)),
//                   const SizedBox(height: 6),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           job['jobType'] ?? '',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Theme.of(context).hintColor,
//                           ),
//                         ),
//                       ),
//                       TextButton(
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => JobDetailsScreen(job: job),
//                             ),
//                           );
//                         },
//                         child: const Text(
//                           'View',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 13,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
