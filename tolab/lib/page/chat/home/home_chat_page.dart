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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,

        backgroundColor:
            theme.appBarTheme.backgroundColor ??
            (isDark ? Colors.black : Colors.white),
        elevation: 1,
        title: Text(
          'خليك محترم في كلامك إحنا هنا نساعد بعض',
          style: TextStyle(
            fontSize: 14,
            color: theme.textTheme.bodyLarge?.color,
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
                    hintText: 'Find your friends or doctors',
                    hintStyle: TextStyle(color: theme.hintColor),
                    prefixIcon: Icon(
                      Icons.search,
                      color: theme.iconTheme.color,
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.grey[800] : Colors.grey[200],
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
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
                  Tab(text: 'مجوعات دراسية'),
                  Tab(text: 'محادثات فردية'),
                ],
                labelColor: theme.primaryColor,
                unselectedLabelColor: theme.unselectedWidgetColor,
                indicatorColor: theme.primaryColor,
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatList(isGroup: true),
          _buildChatList(isGroup: false),
        ],
      ),
    );
  }

  Widget _buildChatList({required bool isGroup}) {
    final theme = Theme.of(context);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 10,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const CircleAvatar(
            backgroundImage: AssetImage('assets/image_App/Tolab.png'),
            radius: 25,
          ),
          title: Text(
            isGroup ? 'مجموعة ماتريكس' : 'Nada022',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          subtitle: Text(
            'آخر رسالة أو وصف سريع ...',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: theme.textTheme.bodySmall?.color),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '1:05 AM',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
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
