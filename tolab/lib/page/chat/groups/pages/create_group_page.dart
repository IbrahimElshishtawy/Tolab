// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final TextEditingController _groupNameController = TextEditingController();
  File? _groupImage;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _groupImage = File(picked.path));
    }
  }

  void _createGroup() {
    final name = _groupNameController.text.trim();
    if (name.isEmpty) {
      _showCupertinoDialog('يرجى كتابة اسم الجروب');
      return;
    }
    // هنا هيكون كود إنشاء الجروب باستخدام Firebase أو حسب ما عندك
    _showCupertinoDialog('تم إنشاء الجروب "$name" بنجاح ✅');
  }

  void _showCupertinoDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('معلومة'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('تمام'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('إنشاء جروب جديد'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: CupertinoColors.systemGrey.withOpacity(0.3),
                  backgroundImage: _groupImage != null
                      ? FileImage(_groupImage!)
                      : null,
                  child: _groupImage == null
                      ? const Icon(CupertinoIcons.camera, size: 36)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              CupertinoTextField(
                controller: _groupNameController,
                placeholder: 'اسم الجروب',
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
              const SizedBox(height: 30),
              CupertinoButton.filled(
                onPressed: _createGroup,
                child: const Text('إنشاء الجروب'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
