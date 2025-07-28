// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();

  bool isLoading = false;

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final postId = const Uuid().v4();

      await FirebaseFirestore.instance.collection('posts').doc(postId).set({
        'postId': postId,
        'content': _contentController.text.trim(),
        'authorId': user.uid,
        'authorName': user.displayName ?? 'Unknown',
        'authorRole': 'Student', // أو احصل عليه من Provider
        'approved': true,
        'shareCount': 0,
        'term': 'Term1',
        'timestamp': Timestamp.now(),
        'views': '',
        'viewsCount': 0,
        'year': 'forthyears',
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل في إضافة البوست: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة بوست')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _contentController,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'محتوى البوست',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'اكتب محتوى البوست' : null,
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitPost,
                      child: const Text('نشر'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
