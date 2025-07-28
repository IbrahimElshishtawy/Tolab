// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tolab/models/post_model.dart';

class EditPostPage extends StatefulWidget {
  final PostModel? post;
  final String? postId;
  final String? initialContent;
  final Map<String, dynamic>? postData;

  const EditPostPage({
    super.key,
    this.post,
    this.postId,
    this.initialContent,
    this.postData,
  });

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(
      text: widget.post?.content ?? widget.initialContent ?? '',
    );
  }

  Future<void> _updatePost() async {
    if (_contentController.text.trim().isEmpty) return;

    final docId = widget.post?.id ?? widget.postId;

    if (docId != null) {
      await FirebaseFirestore.instance.collection('posts').doc(docId).update({
        'content': _contentController.text.trim(),
      });
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromARGB(255, 28, 30, 51), // لون أزرق غامق
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Center(child: const Text('edit post')),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'قم بتحديث محتوى البوست الخاص بك',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _contentController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    labelText: 'المحتوى الجديد',
                    hintText: 'اكتب هنا...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.edit_note),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _updatePost,
                    icon: const Icon(Icons.save),
                    label: const Text(
                      'حفظ التعديلات',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
