import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tolab/core/config/User_Provider.dart';
import 'group_tab.dart';

class HomeChatPage extends StatelessWidget {
  const HomeChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final userRole = context.watch<UserProvider>().role;

    if (userRole == 'dr' || userRole == 'ta') {
      IconButton(
        icon: const Icon(Icons.add_circle_outline),
        onPressed: () {
          Navigator.pushNamed(context, '/createGroup');
        },
      );
    }

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
            'المجموعات',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        actions: [
          if (userRole == 'dr' || userRole == 'ta')
            IconButton(
              icon: const Icon(Icons.add_circle_outline, size: 26),
              onPressed: () {
                Navigator.pushNamed(context, '/createGroup');
              },
            ),
        ],
      ),
      body: const GroupTab(),
    );
  }
}
