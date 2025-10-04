


import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatBubble extends StatelessWidget {
  final bool isCurrentUser;
  final String message;
  final DateTime timestamp;

  const ChatBubble({
    super.key,
    required this.isCurrentUser,
    required this.message,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeString = DateFormat('hh:mm a').format(timestamp);

    final bubbleColor = isCurrentUser
        ? theme.colorScheme.primary
        : theme.brightness == Brightness.dark
            ? Colors.grey.shade800
            : Colors.grey.shade200;

    final textColor = isCurrentUser
        ? Colors.white
        : theme.brightness == Brightness.dark
            ? Colors.white
            : Colors.black87;

    return Column(
      crossAxisAlignment:
          isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Align(
          alignment:
              isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(14),
                topRight: const Radius.circular(14),
                bottomLeft:
                    isCurrentUser ? const Radius.circular(14) : Radius.zero,
                bottomRight:
                    isCurrentUser ? Radius.zero : const Radius.circular(14),
              ),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: theme.shadowColor.withOpacity(0.15),
                  blurRadius: 4,
                  offset: const Offset(1, 2),
                ),
              ],
            ),
            child: Text(
              message,
              style: TextStyle(color: textColor, fontSize: 16, height: 1.3),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
              right: isCurrentUser ? 12 : 0, left: isCurrentUser ? 0 : 12),
          child: Text(
            timeString,
            style: TextStyle(
              fontSize: 11,
              color: theme.brightness == Brightness.dark
                  ? Colors.grey.shade400
                  : Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }
}
