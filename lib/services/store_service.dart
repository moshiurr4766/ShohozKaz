import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

ValueNotifier<StoreService> storeService = ValueNotifier(StoreService());


class StoreService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // 🔧 Updated: now requires uid to use as document ID
  Future<void> storeUserData({
    required String uid,
    required String name,
    required String email,
    required String phone,
  }) async {
    try {
      await firestore.collection('userInfo').doc(uid).set({
        'name': name,
        'email': email,
        'phoneNumber': phone,
        'registrationDate': DateTime.now().toIso8601String(),
      });
    } on FirebaseException {
      rethrow; // or log/handle more gracefully if desired
    }
  }
}
