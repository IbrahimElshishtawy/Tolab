import 'package:flutter/material.dart';
import 'package:tolab_fci/features/subjects/presentation/screens/subjects_screen.dart';
import 'package:tolab_fci/features/subjects/presentation/screens/calendar_screen.dart';
import 'package:tolab_fci/features/community/presentation/screens/community_screen.dart';
import 'package:tolab_fci/features/more/presentation/screens/profile_screen.dart';
import '../widgets/home_header.dart';
import '../widgets/search_bar_widget.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const StudentHomeContent(),
    const SubjectsScreen(),
    const CalendarScreen(),
    const CommunityScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Subjects'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Community'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class StudentHomeContent extends StatelessWidget {
  const StudentHomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const HomeHeader(userName: 'Youssef', role: 'Student'),
            const SearchBarWidget(),
            const SizedBox(height: 20),
            // Add more home content here
          ],
        ),
      ),
    );
  }
}
