import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shohozkaz/features/screen/pages/chatscreen/chat_bubble.dart';
import 'package:shohozkaz/services/auth_service.dart';
import 'package:shohozkaz/services/chat/chat_service.dart';

class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverId;

  const ChatPage({
    super.key,
    required this.receiverEmail,
    required this.receiverId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatServices _chatServices = ChatServices();
  final AuthService _authService = AuthService();
  final ScrollController _scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  @override
  void dispose() {
    focusNode.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void scrollDown() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  void sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      await _chatServices.sendMessage(
        receiverId: widget.receiverId,
        message: _messageController.text.trim(),
      );
      _messageController.clear();
      scrollDown();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _authService.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverEmail),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatServices.getMessages(currentUserId, widget.receiverId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Error loading messages"));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView(
                  controller: _scrollController,
                  children: snapshot.data!.docs.map((doc) {
                    Map<String, dynamic> data =
                        doc.data() as Map<String, dynamic>;

                    bool isCurrentUser = data['senderId'] == currentUserId;

                    return Align(
                      alignment: isCurrentUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: ChatBubble(
                        isCurrentUser: isCurrentUser,
                        message: data['message'] ?? '',
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          _buildUserInput(),
        ],
      ),
    );
  }

  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              focusNode: focusNode,
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Type a message...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: sendMessage,
          ),
        ],
      ),
    );
  }
}
