import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tolab/page/chat/home/create_group_dialog.dart';
import 'package:tolab/page/profile/widget/avatar_generator.dart';

class GroupTab extends StatefulWidget {
  const GroupTab({super.key});
  @override
  State<GroupTab> createState() => _GroupTabState();
}

class _GroupTabState extends State<GroupTab> {
  final currentUser = FirebaseAuth.instance.currentUser;
  bool isTeacher = false;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    checkUserRole();
  }

  Future<void> checkUserRole() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .get();
    final role = doc.data()?['role'];
    if (!mounted) return;
    setState(() {
      isTeacher = role == 'doctor' || role == 'assistant';
      loading = false;
    });
  }

  Widget _buildTeacherView() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _optionButton("الدفعه الأولى", () => showCreateGroupDialog(context)),
        const SizedBox(height: 12),
        _optionButton("الدفعه الثانية", () {
          /* غير مجلد */
        }),
        const SizedBox(height: 12),
        _optionButton("الدفعه الثالثة", () {
          /* ... */
        }),
        const SizedBox(height: 12),
        _optionButton("الدفعه الرابعة", () {
          /* ... */
        }),
      ],
    );
  }

  Widget _optionButton(String title, VoidCallback onTap) {
    return ElevatedButton(onPressed: onTap, child: Text(title));
  }

  Widget _buildStudentView() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('groups')
          .where('members', arrayContains: currentUser!.uid)
          .snapshots(),
      builder: (context, snap) {
        if (snap.hasError) {
          return const Center(child: Text('خطأ في تحميل الجروبات'));
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snap.data!.docs;
        if (docs.isEmpty) return const Center(child: Text('لا توجد مجموعات'));

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final g = docs[i];
            final name = g['name'];
            final subtitle = g['lastMessage'] ?? '';
            final timeField = g['lastMessageTime'] ?? '';
            final timeStr = timeField.toString();
            final formatted = timeStr.length >= 5
                ? timeStr.substring(0, 5)
                : '';
            return ListTile(
              leading: AvatarGenerator(name: name, radius: 26, fontSize: 16),
              title: Text(name),
              subtitle: Text(subtitle),
              trailing: Text(formatted),
              onTap: () {
                /* navigate */
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    return Stack(
      children: [
        isTeacher ? _buildTeacherView() : _buildStudentView(),
        if (isTeacher)
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.blueAccent,
              onPressed: () => showCreateGroupDialog(context),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
      ],
    );
  }
}
