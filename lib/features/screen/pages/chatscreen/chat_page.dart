import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
        duration: const Duration(milliseconds: 300),
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
        titleSpacing: 0,
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('userInfo')
              .doc(widget.receiverId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Text(widget.receiverEmail),
                ],
              );
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final name = (userData['name'] ?? widget.receiverEmail)
                .toString()
                .split(" ")
                .first;
            final profileImage = userData['profileImage'] ?? '';

            return Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: profileImage.isNotEmpty
                      ? NetworkImage(profileImage)
                      : null,
                  child: profileImage.isEmpty
                      ? Text(
                          name[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Text(name, style: const TextStyle(fontSize: 18)),
              ],
            );
          },
        ),
      ),
      body: Column(
        children: [
          // 🔹 MESSAGES AREA
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatServices.getMessages(
                currentUserId,
                widget.receiverId,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Error loading messages"));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                // ✅ Sort messages by timestamp
                docs.sort((a, b) {
                  final t1 = (a['timestamp'] as Timestamp).toDate();
                  final t2 = (b['timestamp'] as Timestamp).toDate();
                  return t1.compareTo(t2);
                });

                // ✅ Scroll automatically after frame render
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });

                return ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  children: _buildMessageList(docs, currentUserId),
                );
              },
            ),
          ),

          // 🔹 INPUT FIELD
          _buildUserInput(),
        ],
      ),
    );
  }

  // 🔹 Build message list with date separators
  List<Widget> _buildMessageList(
    List<QueryDocumentSnapshot> docs,
    String currentUserId,
  ) {
    List<Widget> widgets = [];
    DateTime? lastDate;

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final msgTime = (data['timestamp'] as Timestamp).toDate();
      final isCurrentUser = data['senderId'] == currentUserId;

      final msgDate = DateTime(msgTime.year, msgTime.month, msgTime.day);

      // 🔸 Insert date separator
      if (lastDate == null || msgDate != lastDate) {
        String label;
        final now = DateTime.now();
        final diff = now.difference(msgDate).inDays;

        if (diff == 0) {
          label = "Today";
        } else if (diff == 1) {
          label = "Yesterday";
        } else {
          label = DateFormat('d MMM yyyy').format(msgDate);
        }

        widgets.add(_ChatDateSeparator(label: label));
        lastDate = msgDate;
      }

      // 🔸 Add message bubble
      widgets.add(
        ChatBubble(
          isCurrentUser: isCurrentUser,
          message: data['message'] ?? '',
          timestamp: msgTime,
        ),
      );
    }

    return widgets;
  }

  // 🔹 Message input field
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
          IconButton(icon: const Icon(Icons.send), onPressed: sendMessage),
        ],
      ),
    );
  }
}

// 🔹 Date Separator Widget
class _ChatDateSeparator extends StatelessWidget {
  final String label;
  const _ChatDateSeparator({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = theme.brightness == Brightness.dark
        ? Colors.grey.shade700
        : Colors.grey.shade300;
    final textColor = theme.brightness == Brightness.dark
        ? Colors.white70
        : Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(label, style: TextStyle(fontSize: 12, color: textColor)),
        ),
      ),
    );
  }
}
