// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  bool isLoading = false;

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final post = {
        'title': titleController.text.trim(),
        'content': contentController.text.trim(),
        'authorId': user.uid,
        'authorName': user.displayName ?? 'Unknown',
        'date': DateTime.now(),
        'views': [],
        'viewsCount': 0,
        'shareCount': 0,
        'isApproved': false,
        'pending': true,
      };

      await FirebaseFirestore.instance.collection('posts').add(post);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال البوست للمراجعة.')),
      );

      titleController.clear();
      contentController.clear();
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
      appBar: AppBar(title: const Text('إضافة بوست جديد')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'عنوان البوست'),
                validator: (value) => value!.isEmpty ? 'أدخل العنوان' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: contentController,
                maxLines: 6,
                decoration: const InputDecoration(labelText: 'محتوى البوست'),
                validator: (value) => value!.isEmpty ? 'أدخل المحتوى' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : _submitPost,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('إرسال للمراجعة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
