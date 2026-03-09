import 'package:flutter/material.dart';
import 'package:tolab_fci/features/subjects/presentation/screens/subjects_screen.dart';
import 'package:tolab_fci/features/calendar/ui/calendar_screen.dart';
import 'package:tolab_fci/features/community/ui/community_screen.dart';
import 'package:tolab_fci/features/more/presentation/screens/profile_screen.dart';
import '../../../../core/ui/widgets/university_widgets.dart';
import '../../../../core/ui/widgets/business_widgets.dart';
import '../../../../core/ui/tokens/spacing_tokens.dart';
import '../../../../core/ui/tokens/color_tokens.dart';
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
    final theme = Theme.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HomeHeader(userName: 'Youssef', role: 'Student'),
            const SearchBarWidget(),
            const SizedBox(height: AppSpacing.xxl),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.l),
              child: SectionHeader(title: 'My Enrolled Courses'),
            ),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                itemCount: 3,
                itemBuilder: (context, index) {
                  final subjects = ['Advanced SE', 'Database Admin', 'Computer Ethics'];
                  final codes = ['CS402', 'IS305', 'HU201'];
                  return AppCard(
                    margin: const EdgeInsets.only(right: AppSpacing.m),
                    padding: const EdgeInsets.all(AppSpacing.l),
                    color: index == 0 ? AppColors.primary : Colors.white,
                    child: SizedBox(
                      width: 160,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.auto_stories,
                            color: index == 0 ? Colors.white : AppColors.primary,
                            size: 32,
                          ),
                          const Spacer(),
                          Text(
                            subjects[index],
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: index == 0 ? Colors.white : AppColors.primary,
                            ),
                          ),
                          Text(
                            codes[index],
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: index == 0 ? Colors.white70 : AppColors.grey500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.l),
              child: SectionHeader(title: 'Upcoming Tasks'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
              child: Column(
                children: [
                  AppCard(
                    margin: const EdgeInsets.only(bottom: AppSpacing.m),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.warning,
                        child: Icon(Icons.assignment_late, color: Colors.white),
                      ),
                      title: const Text('Software Architecture Quiz', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Due tomorrow, 10:00 AM'),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  ),
                  AppCard(
                    margin: const EdgeInsets.only(bottom: AppSpacing.m),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.info,
                        child: Icon(Icons.upload_file, color: Colors.white),
                      ),
                      title: const Text('Database Project Submission', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Due in 3 days'),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.l),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Academic Progress',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'You have completed 75% of your semester goals.',
                            style: TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 16),
                          LinearProgressIndicator(
                            value: 0.75,
                            backgroundColor: Colors.white24,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.l),
                    const Icon(Icons.workspace_premium, color: Colors.white, size: 48),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
