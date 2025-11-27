import 'package:eduhub/apps/tolab_student_desktop/lib/src/dashboard/ui/student_nav_item_data.dart';
import 'package:eduhub/apps/tolab_student_desktop/lib/src/dashboard/widgets/student_bottom_nav.dart';
import 'package:eduhub/apps/tolab_student_desktop/lib/src/dashboard/widgets/student_home_cards.dart';
import 'package:eduhub/apps/tolab_student_desktop/lib/src/dashboard/widgets/student_sidebar.dart';
import 'package:eduhub/apps/tolab_student_desktop/lib/src/dashboard/widgets/student_top_bar.dart';
import 'package:flutter/material.dart';

class StudentDesktopHomePage extends StatefulWidget {
  const StudentDesktopHomePage({super.key});

  @override
  State<StudentDesktopHomePage> createState() => _StudentDesktopHomePageState();
}

class _StudentDesktopHomePageState extends State<StudentDesktopHomePage> {
  int _selectedNavIndex = 0;
  DateTime _selectedDay = DateTime.now();

  final _studentName = 'Student Name';
  final _department = 'Computer Science';
  final _academicYear = 'Second Year';

  late final List<StudentNavItemData> _navItems;

  @override
  void initState() {
    super.initState();
    _navItems = const [
      StudentNavItemData(icon: Icons.home_rounded, label: 'Home'),
      StudentNavItemData(icon: Icons.menu_book_rounded, label: 'Subjects'),
      StudentNavItemData(icon: Icons.schedule_rounded, label: 'Schedule'),
      StudentNavItemData(icon: Icons.people_alt_rounded, label: 'Community'),
      StudentNavItemData(icon: Icons.notifications_rounded, label: 'Alerts'),
      StudentNavItemData(icon: Icons.person_rounded, label: 'Profile'),
      StudentNavItemData(icon: Icons.more_horiz_rounded, label: 'More'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Stack(
        children: [
          // ==== Main Layout (sidebar + content) ====
          Row(
            children: [
              StudentSidebar(
                items: _navItems,
                selectedIndex: _selectedNavIndex,
                onItemSelected: _onNavSelected,
              ),
              Expanded(
                child: Column(
                  children: [
                    StudentTopBar(studentName: _studentName),
                    const Divider(height: 1, color: Color(0xFF1E293B)),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 90),
                        // padding bottom عشان الـ bottom nav العائم
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left column: account + lectures
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AccountDetailsCard(
                                    studentName: _studentName,
                                    department: _department,
                                    academicYear: _academicYear,
                                  ),
                                  const SizedBox(height: 24),
                                  UpcomingLecturesCard(
                                    selectedDay: _selectedDay,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            // Right column: calendar + quizzes
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  DayCalendarCard(
                                    selectedDay: _selectedDay,
                                    onDaySelected: (day) {
                                      setState(() {
                                        _selectedDay = day;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                  UpcomingQuizzesCard(
                                    selectedDay: _selectedDay,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ==== Floating bottom nav centered ====
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: Center(
              child: StudentBottomNav(
                items: _navItems,
                selectedIndex: _selectedNavIndex,
                onItemSelected: _onNavSelected,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onNavSelected(int index) {
    setState(() {
      _selectedNavIndex = index;
    });

    // TODO: هنا تربط الـ index بالـ routing
    // مثال:
    // if (index == 1) Navigator.pushNamed(context, AppRoutes.studentSubjects);
  }
}
