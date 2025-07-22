// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 2;

  final List<Widget> _pages = const [
    Text("Page 1"),
    Text("Page 2"),
    Text("Home Page"),
    Text("Page 4"),
    Text("Page 5"),
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Center(child: _pages[_currentIndex]),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Stack(
            children: [
              // الخلفية الدائرية لشريط التنقل
              Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),

              // المؤشر المتحرك (Indicator)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left:
                    _currentIndex *
                    ((MediaQuery.of(context).size.width - 40) / 5),
                bottom: 0,
                child: Container(
                  width: ((MediaQuery.of(context).size.width - 40) / 5),
                  height: 3,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white : Colors.blue.shade800,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // الأيقونات
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BottomNavigationBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  type: BottomNavigationBarType.fixed,
                  currentIndex: _currentIndex,
                  onTap: _onTap,
                  selectedItemColor: isDark
                      ? Colors.white
                      : Colors.blue.shade800,
                  unselectedItemColor: isDark
                      ? Colors.grey.shade500
                      : Colors.grey.shade400,
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                  iconSize: 22,
                  items: const [
                    BottomNavigationBarItem(
                      icon: FaIcon(FontAwesomeIcons.bookOpen),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: FaIcon(FontAwesomeIcons.comments),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: FaIcon(FontAwesomeIcons.house),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: FaIcon(FontAwesomeIcons.calendar),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: FaIcon(FontAwesomeIcons.ellipsisV),
                      label: '',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
