import 'package:flutter/material.dart';

class Usertile extends StatelessWidget {
  final String title;   
  final String subtitle; 
  final String? profileImage; 
  final void Function() onTap;

  const Usertile({
    super.key,
    required this.title,
    required this.onTap,
    this.subtitle = "",
    this.profileImage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.deepOrange.shade200,
          backgroundImage:
              profileImage != null && profileImage!.isNotEmpty ? NetworkImage(profileImage!) : null,
          child: (profileImage == null || profileImage!.isEmpty)
              ? Text(
                  title.isNotEmpty ? title[0].toUpperCase() : "?",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                )
              : null,
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
        trailing: const Icon(Icons.chat_bubble_outline, color: Colors.deepOrange),
      ),
    );
  }
}
