
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shohozkaz/models/massage.dart';

class ChatServices {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Stream all users from `userInfo` collection
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _db.collection('userInfo').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();
        user['uid'] = doc.id; 
        return user;
      }).toList();
    });
  }

  //Create a stable chatRoomId (sorted by uid)
  String _roomId(String a, String b) {
    final ids = [a, b]..sort();
    return ids.join('_');
  }

  //Send a message
  Future<void> sendMessage({
    required String receiverId,
    required String message,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("Not authenticated");

      final senderId = user.uid;
      final senderEmail = user.email ?? '';
      final roomId = _roomId(senderId, receiverId);

      final msg = Message(
        senderId: senderId,
        senderEmail: senderEmail,
        receiverId: receiverId,
        message: message.trim(),
        timestamp: DateTime.now(),
      );

      await _db
          .collection('chatRooms')
          .doc(roomId)
          .collection('messages')
          .add(msg.toMap());

      if (kDebugMode) {
        print("Message sent to $roomId");
      }
    } catch (e) {
      debugPrint("Error sending message: $e");
    }
  }

  //Get messages between two users
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    final roomId = _roomId(userId, otherUserId);
    return _db
        .collection('chatRooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}




