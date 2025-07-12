// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:tolab/Features/posts/pages/posts_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    PostsPage(),
    const Center(child: Text('📚 Subjects')),
    const Center(child: Text('👤 Profile')),
    const Center(child: Text('🎮 Games')),
    const Center(child: Text('⋯ More')),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _pages[_currentIndex],
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 12, vertical: 30),
        child: SizedBox(
          height: 60,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              type: BottomNavigationBarType.fixed,
              backgroundColor: theme.colorScheme.primary,
              selectedItemColor: theme.colorScheme.onPrimary,
              unselectedItemColor: theme.colorScheme.onPrimary.withOpacity(0.6),
              iconSize: 22,
              onTap: (index) => setState(() => _currentIndex = index),
              showSelectedLabels: false,
              showUnselectedLabels: false,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
                BottomNavigationBarItem(icon: Icon(Icons.book), label: ''),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
                BottomNavigationBarItem(
                  icon: Icon(Icons.videogame_asset),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.more_vert_outlined),
                  label: '',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
