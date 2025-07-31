// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> showCreateGroupDialog(BuildContext context) async {
  final TextEditingController nameController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('إنشاء مجموعة جديدة'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: 'اسم المجموعة'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final groupName = nameController.text.trim();
              if (groupName.isEmpty) return;

              await FirebaseFirestore.instance.collection('groups').add({
                'name': groupName,
                'createdBy': currentUser!.uid,
                'members': [currentUser.uid],
                'lastMessage': '',
                'lastMessageTime': '',
                'createdAt': FieldValue.serverTimestamp(),
              });

              Navigator.pop(context);
            },
            child: const Text('إنشاء'),
          ),
        ],
      );
    },
  );
}
