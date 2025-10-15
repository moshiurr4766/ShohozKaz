import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserRatingCalculator {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Calculates and updates the average rating and count for the given [userId].
  Future<void> updateUserRating(String userId) async {
    try {
      // Fetch all feedback documents where this user was rated
      final snapshot = await _firestore
          .collection('userFeedback')
          .where('userId', isEqualTo: userId)
          .get();

      if (snapshot.docs.isEmpty) {
        // If no ratings exist, reset rating in userInfo
        await _firestore.collection('userInfo').doc(userId).set({
          'avgRating': 0.0,
          'ratingCount': 0,
        }, SetOptions(merge: true));
        debugPrint("No feedback found. Rating reset to 0 for user: $userId");
        return;
      }

      double totalRating = 0;
      int count = snapshot.docs.length;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        totalRating += (data['rating'] ?? 0).toDouble();
      }

      double avgRating = totalRating / count;

      // Round to 1 decimal
      double roundedAvg = double.parse(avgRating.toStringAsFixed(1));

      // Update userInfo document
      await _firestore.collection('userInfo').doc(userId).set({
        'avgRating': roundedAvg,
        'ratingCount': count,
        'lastRatingUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint("✅ Updated rating for user $userId → avg: $roundedAvg, count: $count");
    } catch (e) {
      debugPrint("❌ Error updating user rating: $e");
    }
  }
}
