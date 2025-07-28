import 'package:flutter/material.dart';

class HomeChatPage extends StatefulWidget {
  const HomeChatPage({super.key});

  @override
  State<HomeChatPage> createState() => _HomeChatPageState();
}

class _HomeChatPageState extends State<HomeChatPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'خليك محترم في كلامك إحنا هنا نساعد بعض',
          style: TextStyle(fontSize: 14, color: Colors.black),
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
                    hintText: 'Find your friends or doctors',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'جهات دراسية'),
                  Tab(text: 'محادثات فردية'),
                ],
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.black,
                indicatorColor: Colors.blue,
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Chats for study groups
          _buildChatList(isGroup: true),
          // Chats with individuals
          _buildChatList(isGroup: false),
        ],
      ),
    );
  }

  Widget _buildChatList({required bool isGroup}) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 10, // replace with real data count
      itemBuilder: (context, index) {
        return ListTile(
          leading: const CircleAvatar(
            backgroundImage: AssetImage(
              'assets/avatar.png',
            ), // change to NetworkImage
            radius: 25,
          ),
          title: Text(
            isGroup ? 'مجموعة ماتريكس' : 'Nada022',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: const Text(
            'آخر رسالة أو وصف سريع ...',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('1:05 AM', style: TextStyle(fontSize: 12)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '2',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          onTap: () {
            // Navigate to chat
          },
        );
      },
    );
  }
}
