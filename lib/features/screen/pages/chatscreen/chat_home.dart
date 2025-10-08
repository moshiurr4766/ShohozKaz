

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
  final TextEditingController _searchController = TextEditingController();
  String searchText = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        searchText = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ShohozKaz Chat')),
      body: Column(
        children: [
          
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search by name, email, or role...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(child: _buildUserList()),
        ],
      ),
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

        // Filter users by search text
        final filteredUsers = users.where((user) {
          final email = (user['email'] ?? '').toString().toLowerCase();
          final name = (user['name'] ?? '').toString().toLowerCase();
          final role = (user['role'] ?? '').toString().toLowerCase();

          return email.contains(searchText) ||
              name.contains(searchText) ||
              role.contains(searchText);
        }).toList();

        return ListView(
          children: filteredUsers.map<Widget>((userData) {
            return _buildUserListItem(userData, context);
          }).toList(),
        );
      },
    );
  }

  Widget _buildUserListItem(
    Map<String, dynamic> userData,
    BuildContext context,
  ) {
    final currentUser = widget._authService.currentUser;
    final email = userData['email'] ?? 'Unknown User';
    final uid = userData['uid'] ?? '';
    final name = userData['name'] ?? email.split('@')[0];
    final profileImage = userData['profileImage'] ?? '';
    final role = userData['role'] ?? 'user';

    if (email == currentUser?.email) {
      return const SizedBox.shrink(); // hide current user
    }

    return Usertile(
      title: name,
      subtitle: role,
      profileImage: profileImage,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ChatPage(receiverEmail: email, receiverId: uid),
          ),
        );
      },
    );
  }
}





