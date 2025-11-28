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
    required String status,
  }) async {
    try {
      await firestore.collection('userInfo').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'phoneNumber': phone,
        'status':status,
        'registrationDate': DateTime.now().toIso8601String(),
      });
    } on FirebaseException {
      rethrow; // or log/handle more gracefully if desired
    }
  }


  Future<bool> phoneExists(String phone) async {
  final result = await FirebaseFirestore.instance
      .collection('userInfo')
      .where("phoneNumber", isEqualTo: phone)
      .limit(1)
      .get();

  return result.docs.isNotEmpty;
}

}
