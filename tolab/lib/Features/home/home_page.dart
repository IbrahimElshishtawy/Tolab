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
    const PostsPage(),
    const Center(child: Text('📚 Subjects')),
    const Center(child: Text('👤 Profile')),
    const Center(child: Text('🎮 Games')),
    const Center(child: Text('⋯ More')),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color.fromARGB(255, 30, 30, 30)
                  : const Color.fromRGBO(152, 172, 201, 1),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BottomNavigationBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                currentIndex: _currentIndex,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.white.withOpacity(0.6),
                iconSize: 22,
                onTap: (index) {
                  setState(() => _currentIndex = index);
                },
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
      ),
    );
  }
}
