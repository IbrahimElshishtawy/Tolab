import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tolab/page/chat/chat/pages/chat_page.dart';
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
    try {
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
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isTeacher = false;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    return Stack(
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('groups')
              .where('members', arrayContains: currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('خطأ في تحميل الجروبات'));
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final groups = snapshot.data!.docs;

            if (groups.isEmpty) {
              return const Center(child: Text('لا توجد مجموعات'));
            }

            return ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                final name = group['name'];
                final lastMessage = group['lastMessage'] ?? '';
                final time = group['lastMessageTime'] ?? '';

                return ListTile(
                  leading: AvatarGenerator(
                    name: name,
                    radius: 26,
                    fontSize: 16,
                  ),
                  title: Text(name),
                  subtitle: Text(lastMessage),
                  trailing: Text(time.toString().substring(0, 5)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(
                          otherUserId: currentUser!.uid,
                          otherUserName: name,
                          groupId: group.id,
                          groupName: name,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
        if (isTeacher)
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () => showCreateGroupDialog(context),
              child: const Icon(Icons.add),
            ),
          ),
      ],
    );
  }
}
