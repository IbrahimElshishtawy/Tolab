import 'package:flutter/material.dart';
import 'package:tolab_fci/core/theme/app_theme.dart';

import 'package:tolab_fci/presentation/pages/dashboard_screen.dart';

class TolabApp extends StatefulWidget {
  const TolabApp({super.key});

  @override
  State<TolabApp> createState() => _TolabAppState();
}

class _TolabAppState extends State<TolabApp> {
  int _selectedIndex = 0;
  bool _isDarkMode = false;

  final List<({String label, IconData icon, Widget page})> _pages = [
    (
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      page: const DashboardScreen(),
    ),
    (
      label: 'Users',
      icon: Icons.people_outline,
      page: const Placeholder(), // Will be replaced with UsersListScreen
    ),
    (
      label: 'Courses',
      icon: Icons.book_outlined,
      page: const Placeholder(), // Will be replaced with CoursesListScreen
    ),
    (
      label: 'Settings',
      icon: Icons.settings_outlined,
      page: const Placeholder(), // Will be replaced with SettingsScreen
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tolab LMS',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        body: Row(
          children: [
            // Sidebar for desktop
            if (MediaQuery.of(context).size.width >= 768)
              NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) {
                  setState(() => _selectedIndex = index);
                },
                labelType: NavigationRailLabelType.all,
                destinations: _pages
                    .map(
                      (page) => NavigationRailDestination(
                        icon: Icon(page.icon),
                        label: Text(page.label),
                      ),
                    )
                    .toList(),
              ),
            // Main content
            Expanded(
              child: Column(
                children: [
                  // Top app bar
                  AppBar(
                    title: Text(_pages[_selectedIndex].label),
                    actions: [
                      IconButton(
                        icon: Icon(
                          _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                        ),
                        onPressed: () {
                          setState(() => _isDarkMode = !_isDarkMode);
                        },
                      ),
                    ],
                  ),
                  // Page content
                  Expanded(child: _pages[_selectedIndex].page),
                ],
              ),
            ),
          ],
        ),
        // Bottom navigation for mobile
        bottomNavigationBar: MediaQuery.of(context).size.width < 768
            ? BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: (index) {
                  setState(() => _selectedIndex = index);
                },
                items: _pages
                    .map(
                      (page) => BottomNavigationBarItem(
                        icon: Icon(page.icon),
                        label: page.label,
                      ),
                    )
                    .toList(),
              )
            : null,
      ),
    );
  }
}
