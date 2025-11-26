import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iconsax/iconsax.dart';

import 'package:shohozkaz/core/constants.dart';
import 'package:shohozkaz/features/screen/pages/design/employer_drawer.dart';
import 'package:shohozkaz/features/screen/pages/design/widgets/home_banner.dart';
import 'package:shohozkaz/features/screen/pages/search_page/category_search.dart';
import 'package:shohozkaz/features/screen/pages/search_page/search.dart';

class HomeModern extends StatefulWidget {
  const HomeModern({super.key});

  @override
  State<HomeModern> createState() => _HomeModernState();
}

class _HomeModernState extends State<HomeModern> with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // GET TOP RATED WORKERS FROM jobFeedback
  Future<List<Map<String, dynamic>>> getTopRatedWorkers() async {
    final snap = await FirebaseFirestore.instance
        .collection('userInfo')
        //.where('role', isEqualTo: 'Worker') // Only workers
        .where('ratingWorkerCount', isGreaterThan: 0) // Must have reviews
        .get();

    if (snap.docs.isEmpty) return [];

    List<Map<String, dynamic>> workers = snap.docs.map((doc) {
      final data = doc.data();

      return {
        "id": doc.id,
        "name": data['name'] ?? "Unknown",
        "workerLabel": data['workerLabel'] ?? "",
        "imageUrl": data['profileImage'] ?? "",
        "rating": (data['avgWorkerRating'] ?? 0).toDouble(),
        "ratingCount": (data['ratingWorkerCount'] ?? 0).toInt(),
      };
    }).toList();

    // Sort: rating → count
    workers.sort((a, b) {
      int ratingCompare = b["rating"].compareTo(a["rating"]);
      if (ratingCompare != 0) return ratingCompare;

      // If rating equal → compare count
      return b["ratingCount"].compareTo(a["ratingCount"]);
    });

    return workers;
  }

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser?.uid;
    final brightness = Theme.of(context).brightness;

    if (uid == null) {
      return Scaffold(
        backgroundColor: brightness == Brightness.dark
            ? const Color(0xFF0F0F0F)
            : Colors.white,
        body: Center(
          child: Text(
            "Please log in to continue",
            style: TextStyle(
              color: brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.black87,
            ),
          ),
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('userInfo')
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            backgroundColor: brightness == Brightness.dark
                ? const Color(0xFF0F0F0F)
                : Colors.white,
            body: Center(
              child: Text(
                "User data not found",
                style: TextStyle(
                  color: brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.black87,
                ),
              ),
            ),
          );
        }

        final userData = snapshot.data!.data()!;
        final userName = userData['name'] ?? 'User';
        final userImg = userData['profileImage'] ?? '';
        final userRole = userData['role'] ?? 'User';

        return Scaffold(
          drawer: CustomDrawer(
            userName: userName,
            profileImage: userImg.isNotEmpty
                ? userImg
                : 'assets/images/logo/logo.png',
            userType: userRole,
          ),
          backgroundColor: brightness == Brightness.dark
              ? const Color(0xFF0F0F0F)
              : const Color(0xFFF7F7F7),
          body: CustomScrollView(
            slivers: [
              _buildModernHeader(context, userName),
              SliverToBoxAdapter(child: _buildBodyContent(context)),
            ],
          ),
        );
      },
    );
  }

  // HEADER WITH GREETING + SEARCH
  SliverAppBar _buildModernHeader(BuildContext context, String name) {
    final brightness = Theme.of(context).brightness;
    final screenWidth = MediaQuery.of(context).size.width;

    return SliverAppBar(
      automaticallyImplyLeading: false,
      expandedHeight: 225,
      pinned: true,
      backgroundColor: AppColors.button,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Custom menu button
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              child: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Iconsax.menu, color: Colors.white, size: 26),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
            ),

            // Notification button
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 16,
              child: IconButton(
                icon: const Icon(
                  Iconsax.notification,
                  color: Colors.white,
                  size: 22,
                ),
                onPressed: () {},
              ),
            ),

            // Greeting
            Positioned(
              top: MediaQuery.of(context).padding.top + 56,
              left: 20,
              right: 20,
              child: Text(
                "Hello, $name 👋",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: screenWidth < 360 ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            Positioned(
              top: MediaQuery.of(context).padding.top + 92,
              left: 20,
              right: 20,
              child: Text(
                "Find trusted local help in just a few taps.",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),

            // Search bar (tappable)
            Positioned(
              top: MediaQuery.of(context).padding.top + 135,
              left: 16,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: brightness == Brightness.dark
                        ? Colors.grey[200]
                        : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.search_normal,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Search in ShohozKaz",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // BODY CONTENT

  Widget _buildBodyContent(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 18),

          // BANNER SLIDER
          TPromoSlide(
            banners: [
              AppImages.promoBanner1,
              AppImages.promoBanner2,
              AppImages.promoBanner4,
            ],
          ),

          const SizedBox(height: 18),

          // QUICK ACTIONS
          _buildQuickActionsRow(context),

          const SizedBox(height: 24),

          // POPULAR SERVICES
          //_buildCategorySection(context),
          const PopularServicesSection(),

          const SizedBox(height: 24),

          // TOP RATED WORKERS
          _buildTopRatedWorkersSection(context),

          const SizedBox(height: 22),

          // HOW IT WORKS
          Text(
            "How It Works",
            style: TextStyle(
              fontSize: screenWidth < 360 ? 16 : 18,
              fontWeight: FontWeight.w700,
              color: brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Get started in just a few simple steps.",
            style: TextStyle(
              fontSize: 13,
              color: brightness == Brightness.dark
                  ? Colors.grey[400]
                  : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          _buildHowItWorksRow(context),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // QUICK ACTIONS (Find, Post, Top Rated)
  Widget _buildQuickActionsRow(BuildContext context) {
    //final screenWidth = MediaQuery.of(context).size.width;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _quickBtn(
          context,
          icon: Iconsax.briefcase,
          title: "Find Job",
          onTap: () {
            // Navigator.push(context, MaterialPageRoute(builder: (_) => const FindJobsScreen()));
          },
        ),
        _quickBtn(
          context,
          icon: Iconsax.add_circle,
          title: "Post Job",
          onTap: () {
            // Navigator.push(context, MaterialPageRoute(builder: (_) => const PostJobsScreen()));
          },
        ),
        _quickBtn(
          context,
          icon: Iconsax.star,
          title: "Top Rated",
          onTap: () {
            // Can scroll to top rated section, or navigate to a dedicated page
            // For now, do nothing or add custom logic
          },
        ),
      ],
    );
  }

  Widget _quickBtn(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final brightness = Theme.of(context).brightness;

    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(40),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: brightness == Brightness.dark
                  ? const Color(0xFF1E1E1E)
                  : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: brightness == Brightness.dark
                      ? Colors.black.withOpacity(0.4)
                      : Colors.black12,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.button, size: 26),
          ),
        ),
        const SizedBox(height: 6),
        Text(title, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  // HOW IT WORKS
  Widget _buildHowItWorksRow(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    Widget _item(IconData icon, String title, String subtitle) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: brightness == Brightness.dark
                  ? const Color(0xFF2B2B2B)
                  : const Color(0xFFF2ECFF),
              child: Icon(
                icon,
                size: 18,
                color: brightness == Brightness.dark
                    ? Colors.white
                    : AppColors.button,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                height: 1.3,
                color: brightness == Brightness.dark
                    ? Colors.grey[400]
                    : Colors.grey[700],
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _item(
          Iconsax.user_edit,
          "Create Your Profile",
          "Sign up and showcase your skills to local customers.",
        ),
        const SizedBox(width: 12),
        _item(
          Iconsax.briefcase,
          "Find & Apply",
          "Browse local jobs and apply with a single tap.",
        ),
        const SizedBox(width: 12),
        _item(
          Iconsax.money_send,
          "Get Hired & Paid",
          "Complete tasks, get reviews, and receive payments securely.",
        ),
      ],
    );
  }

  // TOP RATED WORKERS (HORIZONTAL) — rating from jobFeedback
  Widget _buildTopRatedWorkersSection(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Top Rated Workers",
              style: TextStyle(
                fontSize: screenWidth < 360 ? 16 : 18,
                fontWeight: FontWeight.w700,
                color: brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        SizedBox(
          height: 135,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: getTopRatedWorkers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    "Top workers will appear here.",
                    style: TextStyle(
                      fontSize: 12,
                      color: brightness == Brightness.dark
                          ? Colors.grey[400]
                          : Colors.grey[700],
                    ),
                  ),
                );
              }

              final workers = snapshot.data!;

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: workers.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final w = workers[index];

                  return _workerCard(
                    context,
                    name: w["name"],
                    workerLabel: w["workerLabel"],
                    imageUrl: w["imageUrl"],
                    rating: w["rating"],
                    ratingCount: w["ratingCount"],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _workerCard(
    BuildContext context, {
    required String name,
    required String workerLabel,
    required String imageUrl,
    required double rating,
    required int ratingCount,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: width * 0.42,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    width: 45,
                    height: 45,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 45,
                    height: 45,
                    color: Colors.grey[300],
                    child: Center(
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : "?",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
          ),

          const SizedBox(height: 6),

          // Name
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),

          const SizedBox(height: 4),

          // Worker Label
          Text(
            workerLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),

          const SizedBox(height: 6),

          // ⭐ Rating + Count
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, size: 14, color: Colors.orange),
              const SizedBox(width: 3),
              Text(
                rating.toStringAsFixed(1),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                " ($ratingCount)",
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PopularServicesSection extends StatefulWidget {
  const PopularServicesSection({super.key});

  @override
  State<PopularServicesSection> createState() => _PopularServicesSectionState();
}

class _PopularServicesSectionState extends State<PopularServicesSection>
    with TickerProviderStateMixin {
  bool _showAllCategories = false;

  // STATIC CATEGORY LIST
  final List<Map<String, dynamic>> categories = const [
    {"name": "Plumbing", "icon": Iconsax.setting_2},
    {"name": "Cleaning", "icon": Iconsax.broom},
    {"name": "Electrician", "icon": Iconsax.electricity},
    {"name": "House Painting", "icon": Iconsax.paintbucket},
    {"name": "AC Repair & Servicing", "icon": Iconsax.airdrop},
    {"name": "Carpentry", "icon": Iconsax.toggle_off},
    {"name": "Laundry & Ironing", "icon": Iconsax.cloud_sunny},
    {"name": "Gardening", "icon": Iconsax.tree},
    {"name": "Mechanic (Bike/Car)", "icon": Iconsax.car},
    {"name": "Home Delivery/Parcel", "icon": Iconsax.truck_fast},
    {"name": "Computer & IT Support", "icon": Iconsax.monitor1},
    {"name": "Private Tutor", "icon": Iconsax.teacher},
    {"name": "Pest Control", "icon": Iconsax.building},
    {"name": "Cooking & Catering", "icon": Iconsax.clock},
    {"name": "Babysitting & Nanny", "icon": Iconsax.user_cirlce_add},
    {"name": "Security Guard", "icon": Iconsax.shield_tick},
    {"name": "House Shift / Movers", "icon": Iconsax.truck_fast},
    {"name": "Mobile Repair", "icon": Iconsax.mobile},
    {"name": "Home Salon & Beauty", "icon": Iconsax.brush_4},
    {"name": "Driving", "icon": Iconsax.driving},
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color tileColor = isDark
        ? const Color(0xFF222222)
        : Colors.grey.shade100;

    final visibleItems = _showAllCategories
        ? categories
        : categories.take(8).toList();

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Popular Services",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),

            LayoutBuilder(
              builder: (context, constraints) {
                const double spacing = 12;
                const int count = 3;

                final double itemWidth =
                    (constraints.maxWidth - spacing * (count - 1)) / count;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: visibleItems.map((item) {
                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CategorySearch(categoryName: item['name']),
                          ),
                        );
                      },
                      child: Container(
                        width: itemWidth,
                        height: 105,
                        decoration: BoxDecoration(
                          color: tileColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? Colors.white12 : Colors.black12,
                            width: 1,
                          ),
                        ),

                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              item['icon'] as IconData,
                              size: 28,
                              color: AppColors.button,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item['name'] as String,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _showAllCategories = !_showAllCategories;
                  });
                },
                child: Text(
                  _showAllCategories ? "Close" : "All Services",
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
