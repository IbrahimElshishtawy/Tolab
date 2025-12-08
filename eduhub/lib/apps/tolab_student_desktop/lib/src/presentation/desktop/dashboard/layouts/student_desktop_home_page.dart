// // lib/apps/tolab_student_desktop/lib/src/dashboard/layouts/student_desktop_home_page.dart

// import 'package:eduhub/apps/tolab_student_desktop/lib/src/presentation/desktop/dashboard/ui/student_nav_item_data.dart';
// import 'package:eduhub/apps/tolab_student_desktop/lib/src/presentation/desktop/dashboard/widgets/student_bottom_nav.dart';
// import 'package:eduhub/apps/tolab_student_desktop/lib/src/presentation/desktop/dashboard/widgets/student_home_cards.dart';
// import 'package:eduhub/apps/tolab_student_desktop/lib/src/presentation/desktop/dashboard/widgets/student_sidebar.dart';
// import 'package:eduhub/apps/tolab_student_desktop/lib/src/presentation/desktop/dashboard/widgets/student_top_bar.dart';
// import 'package:flutter/material.dart';

// // الفيك داتا
// import 'package:eduhub/fake_data/data.dart' as fake;

// class StudentDesktopHomePage extends StatefulWidget {
//   const StudentDesktopHomePage({super.key});

//   @override
//   State<StudentDesktopHomePage> createState() => _StudentDesktopHomePageState();
// }

// class _StudentDesktopHomePageState extends State<StudentDesktopHomePage> {
//   int _selectedNavIndex = 0;
//   DateTime _selectedDay = DateTime.now();

//   // حالة فتح/غلق الـ Sidebar
//   bool _isSidebarCollapsed = false;

//   // بيانات الطالب من fake_data
//   late final Map<String, dynamic> _student;

//   late final List<StudentNavItemData> _navItems;

//   // Getters عشان الكود يبقى أنضف
//   String get _studentName => _student['name'] as String;
//   String get _department => _student['department'] as String;

//   String get _academicYearLabel {
//     final year = _student['year'] as int?;
//     switch (year) {
//       case 1:
//         return 'First Year';
//       case 2:
//         return 'Second Year';
//       case 3:
//         return 'Third Year';
//       case 4:
//         return 'Fourth Year';
//       default:
//         return 'Year ${year ?? ''}';
//     }
//   }

//   String get _studentCode => _student['student_id'] as String;
//   String get _email => _student['email'] as String;
//   String get _status => _student['status'] as String;

//   String get _gpaString {
//     final gpa = _student['gpa_current'] as num;
//     return gpa.toStringAsFixed(2);
//   }

//   @override
//   void initState() {
//     super.initState();

//     // هنا تختار الطالب الحالي (ممكن تربطها بعدين بالـ login)
//     _student = fake.students.firstWhere(
//       (s) => s['student_id'] == 'S001',
//       orElse: () => fake.students.first,
//     );

//     _navItems = const [
//       StudentNavItemData(icon: Icons.home_rounded, label: 'Home'),
//       StudentNavItemData(icon: Icons.menu_book_rounded, label: 'Subjects'),
//       StudentNavItemData(icon: Icons.schedule_rounded, label: 'Schedule'),
//       StudentNavItemData(icon: Icons.people_alt_rounded, label: 'Community'),
//       StudentNavItemData(icon: Icons.notifications_rounded, label: 'Alerts'),
//       StudentNavItemData(icon: Icons.person_rounded, label: 'Profile'),
//       StudentNavItemData(icon: Icons.more_horiz_rounded, label: 'More'),
//     ];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF020617),
//       body: Stack(
//         children: [
//           // ==== Main Layout (sidebar + content) ====
//           Row(
//             children: [
//               StudentSidebar(
//                 items: _navItems,
//                 selectedIndex: _selectedNavIndex,
//                 onItemSelected: _onNavSelected,
//                 isCollapsed: _isSidebarCollapsed,
//                 onLogoTap: _toggleSidebar,
//                 studentName: _studentName,
//                 studentEmail: _email, // مثلاً جاي من fake_data
//               ),

//               Expanded(
//                 child: Column(
//                   children: [
//                     StudentTopBar(
//                       studentName: _studentName,
//                       onLogoTap: _toggleSidebar,
//                     ),
//                     const Divider(height: 1, color: Color(0xFF1E293B)),
//                     Expanded(
//                       child: Padding(
//                         // padding bottom عشان الـ bottom nav العائم
//                         padding: const EdgeInsets.fromLTRB(24, 24, 24, 90),
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // Left column: account + lectures
//                             Expanded(
//                               flex: 2,
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   AccountDetailsCard(
//                                     studentName: _studentName,
//                                     department: _department,
//                                     academicYear: _academicYearLabel,
//                                     studentCode: _studentCode,
//                                     email: _email,
//                                     gpa: _gpaString,
//                                     status: _status,
//                                   ),
//                                   const SizedBox(height: 24),
//                                   UpcomingLecturesCard(
//                                     selectedDay: _selectedDay,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(width: 24),
//                             // Right column: calendar + quizzes
//                             Expanded(
//                               flex: 2,
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   DayCalendarCard(
//                                     selectedDay: _selectedDay,
//                                     onDaySelected: (day) {
//                                       setState(() {
//                                         _selectedDay = day;
//                                       });
//                                     },
//                                   ),
//                                   const SizedBox(height: 24),
//                                   UpcomingQuizzesCard(
//                                     selectedDay: _selectedDay,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),

//           // ==== Floating bottom nav centered ====
//           Positioned(
//             left: 0,
//             right: 0,
//             bottom: 24,
//             child: Center(
//               child: StudentBottomNav(
//                 items: _navItems,
//                 selectedIndex: _selectedNavIndex,
//                 onItemSelected: _onNavSelected,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _onNavSelected(int index) {
//     setState(() {
//       _selectedNavIndex = index;
//     });

//     // TODO: هنا تربط الـ index بالـ routing
//     // مثال:
//     // if (index == 1) Navigator.pushNamed(context, AppRoutes.studentSubjects);
//   }

//   void _toggleSidebar() {
//     setState(() {
//       _isSidebarCollapsed = !_isSidebarCollapsed;
//     });
//   }
// }
