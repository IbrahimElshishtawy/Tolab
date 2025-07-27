// ignore_for_file: file_names, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;

  Future<void> _submitPost() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("يجب تسجيل الدخول أولاً")));
      return;
    }

    setState(() => isLoading = true);

    try {
      await _firestore.collection('posts').add({
        'text': text,
        'userId': user.uid,
        'createdAt': Timestamp.now(),
      });

      Navigator.pop(context); // الرجوع بعد الإضافة
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("إضافة بوست جديد")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "محتوى البوست",
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: isLoading ? null : _submitPost,
              icon: const Icon(Icons.send),
              label: isLoading
                  ? const Text("جاري الإرسال...")
                  : const Text("نشر البوست"),
            ),
          ],
        ),
      ),
    );
  }
}
