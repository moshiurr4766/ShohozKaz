
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

class _HomeState extends State<Home> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserData() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");
    return FirebaseFirestore.instance.collection('userInfo').doc(uid).get();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: getUserData(),
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
                onTap: () {
                  //
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(Iconsax.notification),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: TPromoSlide(banners: [
              AppImages.promoBanner1,
              AppImages.promoBanner2,
              AppImages.promoBanner4,
              AppImages.promoBanner4,

              ],),
          ),
        );
      },
    );
  }
}

