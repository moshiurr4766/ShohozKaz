



import 'package:flutter/material.dart';
import 'package:shohozkaz/features/screen/pages/chatscreen/chat_page.dart';
import 'package:shohozkaz/features/screen/pages/chatscreen/user_tile.dart';
import 'package:shohozkaz/services/auth_service.dart';
import 'package:shohozkaz/services/chat/chat_service.dart';

class ChatHomeScreen extends StatefulWidget {
  ChatHomeScreen({super.key});

  final ChatServices _chatServices = ChatServices();
  final AuthService _authService = AuthService();

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat Home')),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder(
      stream: widget._chatServices.getUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading users'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data ?? [];

        return ListView(
          children: users.map<Widget>((userData) {
            return _buildUserListItem(userData, context);
          }).toList(),
        );
      },
    );
  }

  Widget _buildUserListItem(Map<String, dynamic> userData, BuildContext context) {
    final currentUser = widget._authService.currentUser;
    final email = userData['email'] ?? 'Unknown User';
    final uid = userData['uid'] ?? '';

    if (email == currentUser?.email) {
      return Container(); // don't show current user
    }

    return Usertile(
      text: email,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              receiverEmail: email,
              receiverId: uid, 
            ),
          ),
        );
      },
    );
  }
}
