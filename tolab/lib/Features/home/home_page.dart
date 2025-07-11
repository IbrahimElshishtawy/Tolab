import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const Center(child: Text('📢 Posts Page')),
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
      appBar: AppBar(
        title: const Text('Tolab Home'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
    );
  }
}
