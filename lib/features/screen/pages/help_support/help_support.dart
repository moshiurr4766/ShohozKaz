

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shohozkaz/features/screen/pages/chatscreen/chat_page.dart';
import 'package:shohozkaz/features/screen/pages/help_support/support_ticket.dart';

// Example color utility (replace with your actual AppColors if already defined)
class AppColors {
  static const Color button = Color.fromARGB(255, 235, 118, 45);
}

class SupportHubScreen extends StatelessWidget {
  const SupportHubScreen({super.key});

  Future<DocumentSnapshot?> _getUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return FirebaseFirestore.instance
        .collection('userInfo')
        .doc(user.uid)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor:
            theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface,
        elevation: 0,
      ),
      body: FutureBuilder<DocumentSnapshot?>(
        future: _getUserInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('User info not found.'));
          }

          final user = snapshot.data!;
          final name = user['name'] ?? 'User';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 20),
              _buildHelpCenter(context, name),
              const SizedBox(height: 20),
              Text(
                'Contact us',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              _buildContactCard(
                context,
                title: 'Need assistance?',
                subtitle:
                    'Complete the form and we will get back to you shortly.',
                buttonText: 'Support ticket',
                icon: Icons.add_circle_outline,
              ),
              _buildContactCard(
                context,
                title: 'Live chat',
                subtitle: 'Chat with our support team.',
                buttonText: 'Live chat',
                icon: Icons.chat_bubble_outline,
              ),
              _buildContactCard(
                context,
                title: 'Still need help?',
                subtitle: 'To speak with our support team, call us at',
                phone: '+8801307-266218',
                icon: Icons.phone,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHelpCenter(BuildContext context, String name) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, $name, how can we help you?',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Your one-stop solution for all your needs. Find answers, troubleshoot issues, and explore guides.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    String? buttonText,
    String? phone,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.button, size: 30),
          const SizedBox(height: 10),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(subtitle, style: theme.textTheme.bodyMedium),

          if (buttonText != null) ...[
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () async {
                if (title == 'Need assistance?') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SupportTicket()),
                  );
                } else if (title == 'Live chat') {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    // Navigate immediately
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(
                          receiverId: 'adgWoNl5c2TZa5M523ZsWurc5JM2',
                          receiverEmail: 'shohozkaz@gmail.com',
                        ),
                      ),
                    );

                    // Run Firestore logic asynchronously (non-blocking)
                    Future(() async {
                      final userDoc = await FirebaseFirestore.instance
                          .collection('userInfo')
                          .doc(user.uid)
                          .get();

                      final userData = userDoc.data() ?? {};

                      await FirebaseFirestore.instance
                          .collection('supportLiveChat')
                          .doc(user.uid)
                          .set({
                        'uid': user.uid,
                        'email': user.email,
                        'name': userData['name'] ?? '',
                        'location': userData['location'] ?? '',
                        'phoneNumber': userData['phoneNumber'] ?? '',
                        'profileImage': userData['profileImage'] ?? '',
                        'role': userData['role'] ?? '',
                        'status': userData['status'] ?? '',
                        'timestamp': FieldValue.serverTimestamp(),
                      }, SetOptions(merge: true));
                    });
                  }
                }
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                buttonText,
                style: const TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.button,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],

          if (phone != null) ...[
            const SizedBox(height: 8),
            Text(
              phone,
              style: const TextStyle(
                color: AppColors.button,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
