import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tolab_fci/features/home/presentation/screens/student_home_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    StudentHomeScreen(),
    Center(child: Text('Search')),
    Center(child: Text('Profile')),
    Center(child: Text('Profile')),
    Center(child: Text('Profile')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Color(0XFF023EC5),
        unselectedItemColor: Color(0XFF000000),
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed, // important if > 3 items
        items: [
           BottomNavigationBarItem(
            icon: SvgPicture.asset("assets/svgs/home.svg"),
            activeIcon: SvgPicture.asset("assets/svgs/active_home.svg"),
            label: 'الرئيسية',
          ),
           BottomNavigationBarItem(
            icon: SvgPicture.asset("assets/svgs/subject.svg"),
            activeIcon: SvgPicture.asset("assets/svgs/active_subject.svg"),
            label: 'المواد',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset("assets/svgs/schedule.svg"),
            activeIcon: SvgPicture.asset("assets/svgs/active_schedule.svg"),
            label: 'الجدول',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset("assets/svgs/community.svg"),
            activeIcon: SvgPicture.asset("assets/svgs/active_community.svg"),
            label: 'المجتمع',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset("assets/svgs/other.svg"),
            activeIcon: SvgPicture.asset("assets/svgs/active_other.svg"),
            label: 'المزيد',
          ),
        ],
      ),
    );
  }
}
