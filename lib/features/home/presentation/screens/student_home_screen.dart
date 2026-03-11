import 'package:flutter/material.dart';
import 'package:tolab_fci/features/community/presentation/screens/community_screen.dart';
import 'package:tolab_fci/features/home/presentation/widgets/student/student_bottom_navigation.dart';
import 'package:tolab_fci/features/home/presentation/widgets/student/student_home_content.dart';
import 'package:tolab_fci/features/more/presentation/screens/profile_screen.dart';
import 'package:tolab_fci/features/subjects/presentation/screens/calendar_screen.dart';
import 'package:tolab_fci/features/subjects/presentation/screens/subjects_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    StudentHomeContent(),
    SubjectsScreen(),
    CalendarScreen(),
    CommunityScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: _screens[_selectedIndex],
      bottomNavigationBar: StudentBottomNavigation(
        selectedIndex: _selectedIndex,
        onSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
