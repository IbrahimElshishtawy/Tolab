import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tolab/page/chat/chat/pages/chat_page.dart';

import 'package:tolab/page/profile/widget/avatar_generator.dart';

class HomeChatPage extends StatefulWidget {
  const HomeChatPage({super.key});

  @override
  State<HomeChatPage> createState() => _HomeChatPageState();
}

class _HomeChatPageState extends State<HomeChatPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0.5,
        backgroundColor:
            theme.appBarTheme.backgroundColor ??
            (isDark ? Colors.black : Colors.white),
        title: const Center(
          child: Text(
            'الدردشات',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'بحث عن شخص أو جروب...',
                    prefixIcon: Icon(
                      Icons.search,
                      color: theme.iconTheme.color,
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.grey[800] : Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                ),
              ),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'المجموعات'),
                  Tab(text: 'الأصدقاء'),
                ],
                labelColor: theme.primaryColor,
                unselectedLabelColor: theme.unselectedWidgetColor,
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildGroupList(), _buildFriendChats()],
      ),
    );
  }

  // ✅ جلب الجروبات من Firestore
  Widget _buildGroupList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('groups').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final groups = snapshot.data!.docs;

        return ListView.builder(
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];
            final name = group['name'];

            return ListTile(
              leading: AvatarGenerator(name: name, radius: 26, fontSize: 16),
              title: Text(name),
              subtitle: const Text('رسائل المجموعة...'),
              onTap: () {
                // TODO: افتح صفحة شات المجموعة
              },
            );
          },
        );
      },
    );
  }

  // ✅ جلب دردشات الأصدقاء من Firestore
  Widget _buildFriendChats() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final chats = snapshot.data!.docs;

        return ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index];
            final otherUserId = (chat['participants'] as List).firstWhere(
              (id) => id != currentUser!.uid,
            );

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(otherUserId)
                  .get(),
              builder: (context, userSnap) {
                if (!userSnap.hasData) return const SizedBox();

                final user = userSnap.data!;
                final name = user['name'];

                return ListTile(
                  leading: AvatarGenerator(
                    name: name,
                    radius: 26,
                    fontSize: 16,
                  ),
                  title: Text(name),
                  subtitle: Text(chat['lastMessage'] ?? ''),
                  trailing: Text('🕓'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(
                          receiverId: otherUserId,
                          receiverName: name,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
