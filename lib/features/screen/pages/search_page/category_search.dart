// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:shohozkaz/features/screen/pages/jobs/job_details_screen.dart';

// class CategorySearch extends StatefulWidget {
//   final String categoryName;

//   const CategorySearch({super.key, required this.categoryName});

//   @override
//   State<CategorySearch> createState() => _CategorySearchState();
// }

// class _CategorySearchState extends State<CategorySearch> {
//   String userLocation = "";
//   bool loading = true;

//   String searchQuery = "";
//   List<Map<String, dynamic>> allJobs = [];
//   List<Map<String, dynamic>> displayedJobs = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadAllData();
//   }

//   // ------------------------------------------------------
//   // LOAD USER LOCATION + JOBS + SORT BY CATEGORY & RATING
//   // ------------------------------------------------------
//   Future<void> _loadAllData() async {
//     final uid = FirebaseAuth.instance.currentUser?.uid;
//     if (uid == null) return;

//     // 1️⃣ Load user location
//     final userSnap =
//         await FirebaseFirestore.instance.collection("userInfo").doc(uid).get();
//     userLocation = userSnap["location"] ?? "";

//     // 2️⃣ Load jobs
//     final jobSnap = await FirebaseFirestore.instance
//         .collection("jobs")
//         .orderBy("postedAt", descending: true)
//         .get();

//     allJobs = jobSnap.docs
//         .map<Map<String, dynamic>>((e) => e.data())
//         .toList();

//     // 3️⃣ Apply sorting
//     displayedJobs = await _sortJobs(allJobs);

//     setState(() => loading = false);
//   }

//   // ------------------------------------------------------
//   // SORT BY: 1) Category + Location
//   //          2) Category only
//   //          3) Others
//   //          Then sort each by rating
//   // ------------------------------------------------------
//   Future<List<Map<String, dynamic>>> _sortJobs(
//       List<Map<String, dynamic>> jobs) async {
//     final cat = widget.categoryName.toLowerCase();

//     List<Map<String, dynamic>> catLoc = [];
//     List<Map<String, dynamic>> catOnly = [];
//     List<Map<String, dynamic>> others = [];

//     for (var job in jobs) {
//       String jobCat = (job["category"] ?? "").toString().toLowerCase();
//       String jobLoc = (job["location"] ?? "");

//       if (jobCat.contains(cat) && jobLoc == userLocation) {
//         catLoc.add(job);
//       } else if (jobCat.contains(cat)) {
//         catOnly.add(job);
//       } else {
//         others.add(job);
//       }
//     }

//     await _attachRatings(catLoc);
//     await _attachRatings(catOnly);
//     await _attachRatings(others);

//     catLoc.sort((a, b) => b["avgRating"].compareTo(a["avgRating"]));
//     catOnly.sort((a, b) => b["avgRating"].compareTo(a["avgRating"]));
//     others.sort((a, b) => b["avgRating"].compareTo(a["avgRating"]));

//     return [...catLoc, ...catOnly, ...others];
//   }

//   // ------------------------------------------------------
//   // GET AVERAGE RATING FOR JOB
//   // ------------------------------------------------------
//   Future<void> _attachRatings(List<Map<String, dynamic>> jobs) async {
//     for (var job in jobs) {
//       final jobId = job["jobId"] ?? "";

//       final snap = await FirebaseFirestore.instance
//           .collection("jobFeedback")
//           .where("jobId", isEqualTo: jobId)
//           .get();

//       if (snap.docs.isEmpty) {
//         job["avgRating"] = 0.0;
//       } else {
//         double total = 0;
//         for (var doc in snap.docs) {
//           total += (doc["rating"] ?? 0).toDouble();
//         }
//         job["avgRating"] = total / snap.docs.length;
//       }
//     }
//   }

//   // ------------------------------------------------------
//   // FILTER RESULTS IN LIVE SEARCH
//   // ------------------------------------------------------
//   List<Map<String, dynamic>> _applySearchFilter() {
//     if (searchQuery.isEmpty) return displayedJobs;

//     return displayedJobs.where((job) {
//       return job.values.any((v) =>
//           v.toString().toLowerCase().contains(searchQuery.toLowerCase()));
//     }).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final brightness = Theme.of(context).brightness;
//     final results = _applySearchFilter();

//     return Scaffold(
//       backgroundColor:
//           brightness == Brightness.dark ? const Color(0xFF0F0F0F) : Colors.grey[100],
//       appBar: AppBar(
//         title: Text(
//           widget.categoryName,
//           style: TextStyle(
//               color: brightness == Brightness.dark ? Colors.white : Colors.black),
//         ),
//         backgroundColor:
//             brightness == Brightness.dark ? const Color(0xFF1A1A1A) : Colors.white,
//         iconTheme: IconThemeData(
//           color: brightness == Brightness.dark ? Colors.white : Colors.black,
//         ),
//       ),

//       // ------------------- BODY -------------------
//       body: loading
//           ? const Center(child: CircularProgressIndicator())
//           : Column(
//               children: [
//                 // SEARCH FIELD
//                 _searchBox(context),

//                 Expanded(
//                   child: results.isEmpty
//                       ? Center(
//                           child: Text(
//                             "No results found.",
//                             style: TextStyle(
//                               color: brightness == Brightness.dark
//                                   ? Colors.grey[400]
//                                   : Colors.black54,
//                               fontSize: 16,
//                             ),
//                           ),
//                         )
//                       : ListView.builder(
//                           padding: const EdgeInsets.all(12),
//                           itemCount: results.length,
//                           itemBuilder: (context, index) {
//                             return _jobTile(context, results[index]);
//                           },
//                         ),
//                 ),
//               ],
//             ),
//     );
//   }

//   // ---------------- SEARCH BOX LIVE ----------------
//   Widget _searchBox(BuildContext context) {
//     final brightness = Theme.of(context).brightness;
//     return Container(
//       padding: const EdgeInsets.all(12),
//       child: TextField(
//         onChanged: (v) => setState(() => searchQuery = v),
//         decoration: InputDecoration(
//           hintText: "Search within ${widget.categoryName}",
//           hintStyle: TextStyle(
//               color: brightness == Brightness.dark ? Colors.grey[400] : Colors.grey),
//           prefixIcon: const Icon(Icons.search),
//           filled: true,
//           fillColor: brightness == Brightness.dark
//               ? const Color(0xFF1A1A1A)
//               : Colors.white,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide.none,
//           ),
//         ),
//       ),
//     );
//   }

//   // ---------------- JOB TILE ----------------
//   Widget _jobTile(BuildContext context, Map<String, dynamic> job) {
//     final brightness = Theme.of(context).brightness;
//     final rating = job["avgRating"] ?? 0.0;

//     return InkWell(
//       onTap: () {
//         Navigator.push(
//             context, MaterialPageRoute(builder: (_) => JobDetailsScreen(job: job)));
//       },
//       child: Card(
//         margin: const EdgeInsets.only(bottom: 12),
//         elevation: 3,
//         color:
//             brightness == Brightness.dark ? const Color(0xFF1A1A1A) : Colors.white,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//         child: Padding(
//           padding: const EdgeInsets.all(12),
//           child: Row(
//             children: [
//               // image
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(10),
//                 child: Container(
//                   height: 60,
//                   width: 60,
//                   color:
//                       brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[300],
//                   child: (job["imageUrl"] ?? "").toString().isNotEmpty
//                       ? Image.network(job["imageUrl"], fit: BoxFit.cover)
//                       : Icon(Icons.work, size: 28, color: Colors.grey),
//                 ),
//               ),
//               const SizedBox(width: 12),

//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(job["title"] ?? "",
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.bold,
//                             color: brightness == Brightness.dark
//                                 ? Colors.white
//                                 : Colors.black)),
//                     Text(job["location"] ?? "",
//                         style: TextStyle(
//                             fontSize: 12,
//                             color: brightness == Brightness.dark
//                                 ? Colors.grey[400]
//                                 : Colors.grey[700])),
//                     const SizedBox(height: 6),
//                     Text("৳ ${job["salary"]}",
//                         style: const TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.green)),
//                     const SizedBox(height: 6),

//                     Row(
//                       children: [
//                         Icon(Icons.star,
//                             size: 16,
//                             color: rating > 0 ? Colors.orange : Colors.grey),
//                         const SizedBox(width: 4),
//                         Text(
//                           rating == 0 ? "No ratings" : rating.toStringAsFixed(1),
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 12,
//                               color: brightness == Brightness.dark
//                                   ? Colors.white
//                                   : Colors.black),
//                         ),
//                       ],
//                     )
//                   ],
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }












import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shohozkaz/features/screen/pages/jobs/job_details_screen.dart';

class CategorySearch extends StatefulWidget {
  final String categoryName;

  const CategorySearch({super.key, required this.categoryName});

  @override
  State<CategorySearch> createState() => _CategorySearchState();
}

class _CategorySearchState extends State<CategorySearch> {
  bool loading = true;

  String searchQuery = "";
  List<Map<String, dynamic>> allJobs = [];
  List<Map<String, dynamic>> displayedJobs = [];

  @override
  void initState() {
    super.initState();
    _loadCategoryJobs();
  }

  // ------------------------------------------------------
  // LOAD ONLY JOBS WHERE skill == selected category
  // ------------------------------------------------------
  Future<void> _loadCategoryJobs() async {
    final selectedCat = widget.categoryName.toLowerCase();

    final jobSnap = await FirebaseFirestore.instance
        .collection("jobs")
        .orderBy("postedAt", descending: true)
        .get();

    List<Map<String, dynamic>> categoryJobs = [];

    for (var doc in jobSnap.docs) {
      final data = doc.data();
      String skill = (data["skill"] ?? "").toString().toLowerCase();

      if (skill == selectedCat) {
        categoryJobs.add(data);
      }
    }

    // Attach ratings
    await _attachRatings(categoryJobs);

    // Sort by rating DESC
    categoryJobs.sort((a, b) => b["avgRating"].compareTo(a["avgRating"]));

    setState(() {
      allJobs = categoryJobs;
      displayedJobs = allJobs;
      loading = false;
    });
  }

  // ------------------------------------------------------
  // GET AVERAGE RATING FOR EACH JOB
  // ------------------------------------------------------
  Future<void> _attachRatings(List<Map<String, dynamic>> jobs) async {
    for (var job in jobs) {
      final jobId = job["jobId"] ?? "";

      final snap = await FirebaseFirestore.instance
          .collection("jobFeedback")
          .where("jobId", isEqualTo: jobId)
          .get();

      if (snap.docs.isEmpty) {
        job["avgRating"] = 0.0;
        job["ratingCount"] = 0;
      } else {
        double total = 0;
        for (var doc in snap.docs) {
          total += (doc["rating"] ?? 0).toDouble();
        }
        job["avgRating"] = total / snap.docs.length;
        job["ratingCount"] = snap.docs.length;
      }
    }
  }

  // ------------------------------------------------------
  // LIVE SEARCH FILTERING
  // ------------------------------------------------------
  void _searchJobs(String query) {
    searchQuery = query.toLowerCase();

    if (searchQuery.isEmpty) {
      displayedJobs = allJobs;
    } else {
      displayedJobs = allJobs.where((job) {
        return job.values.any((value) =>
            value.toString().toLowerCase().contains(searchQuery));
      }).toList();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor:
          brightness == Brightness.dark ? const Color(0xFF0F0F0F) : Colors.grey[100],
      appBar: AppBar(
        title: Text(
          widget.categoryName,
          style: TextStyle(
              color: brightness == Brightness.dark ? Colors.white : Colors.black),
        ),
        backgroundColor:
            brightness == Brightness.dark ? const Color(0xFF1A1A1A) : Colors.white,
        iconTheme: IconThemeData(
          color: brightness == Brightness.dark ? Colors.white : Colors.black,
        ),
      ),

      // ------------------- BODY -------------------
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _searchBox(context),

                Expanded(
                  child: displayedJobs.isEmpty
                      ? Center(
                          child: Text(
                            "No results found.",
                            style: TextStyle(
                              color: brightness == Brightness.dark
                                  ? Colors.grey[400]
                                  : Colors.black54,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: displayedJobs.length,
                          itemBuilder: (context, index) {
                            return _jobTile(context, displayedJobs[index]);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  // ---------------- SEARCH BAR ----------------
  Widget _searchBox(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Container(
      padding: const EdgeInsets.all(12),
      child: TextField(
        onChanged: _searchJobs,
        decoration: InputDecoration(
          hintText: "Search by title, location, salary…",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: brightness == Brightness.dark
              ? const Color(0xFF1A1A1A)
              : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ---------------- JOB TILE ----------------
  Widget _jobTile(BuildContext context, Map<String, dynamic> job) {
    final brightness = Theme.of(context).brightness;
    final rating = job["avgRating"] ?? 0.0;

    return InkWell(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => JobDetailsScreen(job: job)));
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        color:
            brightness == Brightness.dark ? const Color(0xFF1A1A1A) : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 60,
                  width: 60,
                  color: brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.grey[300],
                  child: (job["imageUrl"] ?? "").toString().isNotEmpty
                      ? Image.network(job["imageUrl"], fit: BoxFit.cover)
                      : Icon(Icons.work, size: 28, color: Colors.grey),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job["title"] ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black)),

                    Text(job["location"] ?? "",
                        style: TextStyle(
                            fontSize: 12,
                            color: brightness == Brightness.dark
                                ? Colors.grey[400]
                                : Colors.grey[700])),

                    const SizedBox(height: 4),

                    Text("৳ ${job["salary"]}",
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green)),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Icon(Icons.star,
                            size: 16,
                            color: rating > 0 ? Colors.orange : Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          rating == 0
                              ? "No ratings"
                              : "${rating.toStringAsFixed(1)} (${job["ratingCount"]})",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
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

