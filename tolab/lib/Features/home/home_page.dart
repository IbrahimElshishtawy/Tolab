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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tolab Home'),
        backgroundColor: const Color.fromRGBO(152, 172, 201, 1),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 35),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            backgroundColor: const Color.fromARGB(255, 18, 18, 19),
            currentIndex: _currentIndex,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color.fromRGBO(152, 172, 201, 1),
            unselectedItemColor: const Color.fromARGB(255, 255, 255, 255),
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
