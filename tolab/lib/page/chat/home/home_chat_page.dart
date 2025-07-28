import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tolab/page/chat/groups/pages/group_chat_page.dart';

class HomeChatPage extends StatelessWidget {
  const HomeChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final currentUser = FirebaseAuth.instance.currentUser;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('المحادثات الجماعية'),
      ),
      child: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('groups').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CupertinoActivityIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('لا توجد مجموعات حالياً'));
            }

            final groups = snapshot.data!.docs;

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: groups.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final group = groups[index];
                final groupId = group.id;
                final groupName = group['name'];
                final groupDesc = group['description'];

                return FutureBuilder<int>(
                  future: _getUnreadMessagesCount(groupId, currentUser!.uid),
                  builder: (context, snapshot) {
                    final unreadCount = snapshot.data ?? 0;

                    return GestureDetector(
                      onTap: () {
                        // عند الضغط يتم فتح صفحة المحادثة وتحديث وقت الدخول
                        FirebaseFirestore.instance
                            .collection('groups')
                            .doc(groupId)
                            .collection('members')
                            .doc(currentUser.uid)
                            .set({
                              'lastSeen': Timestamp.now(),
                            }, SetOptions(merge: true));

                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (_) => GroupChatPage(
                              groupId: groupId,
                              groupName: groupName,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? CupertinoColors.systemGrey6
                              : CupertinoColors.systemGrey5,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 25,
                              child: Icon(CupertinoIcons.group_solid),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    groupName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (groupDesc != null &&
                                      groupDesc.toString().isNotEmpty)
                                    Text(
                                      groupDesc,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isDark
                                            ? CupertinoColors.systemGrey
                                            : Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (unreadCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: CupertinoColors.systemRed,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$unreadCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            const SizedBox(width: 4),
                            const Icon(CupertinoIcons.chevron_forward),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<int> _getUnreadMessagesCount(String groupId, String userId) async {
    final memberDoc = await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .doc(userId)
        .get();

    Timestamp? lastSeen;
    if (memberDoc.exists && memberDoc.data()!.containsKey('lastSeen')) {
      lastSeen = memberDoc['lastSeen'];
    }

    final query = FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('messages');

    QuerySnapshot snapshot;

    if (lastSeen != null) {
      snapshot = await query.where('timestamp', isGreaterThan: lastSeen).get();
    } else {
      snapshot = await query.get();
    }

    return snapshot.docs.length;
  }
}
