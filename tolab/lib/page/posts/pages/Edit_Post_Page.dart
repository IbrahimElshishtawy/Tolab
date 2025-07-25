// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tolab/models/post_model.dart';

class EditPostPage extends StatefulWidget {
  final PostModel post;
  const EditPostPage({super.key, required this.post});

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.post.content);
  }

  Future<void> _updatePost() async {
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post.id)
        .update({'content': _contentController.text});

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تعديل البوست')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'محتوى البوست'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _updatePost, child: const Text('تحديث')),
          ],
        ),
      ),
    );
  }
}
