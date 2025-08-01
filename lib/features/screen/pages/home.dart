import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shohozkaz/core/constants.dart';
import 'package:shohozkaz/features/screen/pages/design/drawer.dart';
import 'package:shohozkaz/features/screen/pages/design/widgets/home_banner.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _showAllCategories = false;
  late Future<DocumentSnapshot<Map<String, dynamic>>> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = getUserData();
  }

  final List<Map<String, dynamic>> _categories = [
    {"name": "Plumbing", "icon": Iconsax.setting_2},
    {"name": "Cleaning", "icon": Iconsax.broom},
    {"name": "Electrician", "icon": Iconsax.electricity},
    {"name": "Painting", "icon": Iconsax.paintbucket},
    {"name": "AC Repair", "icon": Iconsax.airdrop},
    {"name": "Carpentry", "icon": Iconsax.toggle_off},
    {"name": "Laundry", "icon": Iconsax.cloud_sunny},
    {"name": "Gardening", "icon": Iconsax.tree},
    {"name": "Mechanic", "icon": Iconsax.car},
    {"name": "Delivery", "icon": Iconsax.truck_fast},
    {"name": "Computer Help", "icon": Iconsax.monitor1},
    {"name": "Tutor", "icon": Iconsax.teacher},
    {"name": "Pest Control", "icon": Iconsax.building},
    {"name": "Cooking", "icon": Iconsax.clock},
    {"name": "Babysitting", "icon": Iconsax.user_cirlce_add},
    {"name": "Security", "icon": Iconsax.shield_tick},
  ];

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserData() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");
    return FirebaseFirestore.instance.collection('userInfo').doc(uid).get();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text("User data not found")),
          );
        }

        final userData = snapshot.data!.data()!;
        final userName = userData['name'] ?? 'No Name';
        final userType = userData['type'] ?? 'Unknown';

        return Scaffold(
          drawer: CustomDrawer(
            userName: userName,
            profileImage: 'assets/images/logo/logo.png',
            userType: userType,
          ),
          appBar: AppBar(
            title: const Text("ShozKaz"),
            centerTitle: true,
            actions: [
              InkWell(
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                hoverColor: Colors.transparent,
                onTap: () {},
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(Iconsax.notification),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: TPromoSlide(
                    banners: [
                      AppImages.promoBanner1,
                      AppImages.promoBanner2,
                      AppImages.promoBanner4,
                      AppImages.promoBanner4,
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                buildCategorySection(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildCategorySection() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color actionColor = isDark
        ? const Color.fromARGB(255, 57, 57, 57)
        : Colors.grey.shade100;

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          //color: isDark ? Colors.black : Colors.white,
          //borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "What Do You Need?",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                double maxWidth = constraints.maxWidth;
                int count = 4;
                double spacing = 12;
                double itemWidth = (maxWidth - (spacing * (count - 1))) / count;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: (_showAllCategories ? _categories : _categories.take(8))
                      .map(
                        (item) => GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/${item['name']}');
                          },
                          child: Container(
                            width: itemWidth,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: actionColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: actionColor),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  item['icon'],
                                  size: 28,
                                  color: AppColors.button,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item['name'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 5),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _showAllCategories = !_showAllCategories;
                  });
                },
                style: ButtonStyle(
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  splashFactory: NoSplash.splashFactory,
                ),
                child: Text(
                  _showAllCategories ? "Close" : "All Services",
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}













