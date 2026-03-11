import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:tolab_fci/features/community/presentation/screens/community_screen.dart';
import 'package:tolab_fci/features/home/presentation/widgets/dashboard_shell.dart';
import 'package:tolab_fci/features/home/presentation/widgets/home_header.dart';
import 'package:tolab_fci/features/home/presentation/widgets/quick_action_card.dart';
import 'package:tolab_fci/features/home/presentation/widgets/search_bar_widget.dart';
import 'package:tolab_fci/features/more/presentation/screens/profile_screen.dart';
import 'package:tolab_fci/features/subjects/data/models.dart';
import 'package:tolab_fci/features/subjects/presentation/screens/calendar_screen.dart';
import 'package:tolab_fci/features/subjects/presentation/screens/subjects_screen.dart';
import 'package:tolab_fci/features/subjects/redux/subjects_actions.dart';
import 'package:tolab_fci/redux/app_state.dart';

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
      backgroundColor: const Color(0xFFF3F7FC),
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x140E2A47),
              blurRadius: 28,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            height: 74,
            backgroundColor: Colors.transparent,
            indicatorColor: const Color(0xFFE6F0FF),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.menu_book_rounded),
                label: 'Subjects',
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_month_rounded),
                label: 'Schedule',
              ),
              NavigationDestination(
                icon: Icon(Icons.forum_rounded),
                label: 'Community',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StudentHomeContent extends StatelessWidget {
  const StudentHomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _StudentHomeViewModel>(
      onInit: (store) => store.dispatch(FetchSubjectsAction()),
      converter: _StudentHomeViewModel.fromStore,
      builder: (context, vm) {
        return SafeArea(
          child: Stack(
            children: [
              const DashboardOrb(
                size: 220,
                top: -100,
                right: -30,
                colors: [Color(0xFFCADFFF), Color(0xFF8EB6FF)],
              ),
              const DashboardOrb(
                size: 180,
                top: 220,
                left: -70,
                colors: [Color(0xFFE7F0FF), Color(0xFFB7D0FF)],
              ),
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        HomeHeader(userName: vm.userName, role: 'Student'),
                        const SearchBarWidget(
                          hintText: 'Search subjects, tasks, or materials...',
                        ),
                        const SizedBox(height: 18),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _StudentOverviewCard(userName: vm.userName),
                        ),
                        const SizedBox(height: 16),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: _DailyProgressStrip(),
                        ),
                        const SizedBox(height: 28),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: DashboardSectionTitle(
                            title: 'Quick Access',
                            actionLabel: 'This Week',
                            subtitle: 'Jump to the most-used student tools',
                          ),
                        ),
                        const SizedBox(height: 14),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 1.18,
                            children: [
                              QuickActionCard(
                                title: 'Today\nSchedule',
                                icon: Icons.calendar_today_rounded,
                                color: Colors.indigo,
                                onTap: () {},
                              ),
                              QuickActionCard(
                                title: 'Pending\nTasks',
                                icon: Icons.assignment_turned_in_outlined,
                                color: Colors.orange,
                                onTap: () {},
                              ),
                              QuickActionCard(
                                title: 'Lecture\nMaterials',
                                icon: Icons.play_lesson_outlined,
                                color: Colors.teal,
                                onTap: () {},
                              ),
                              QuickActionCard(
                                title: 'Discussion\nBoard',
                                icon: Icons.forum_outlined,
                                color: Colors.pink,
                                onTap: () {},
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: DashboardSectionTitle(
                            title: 'Continue Learning',
                            actionLabel:
                                vm.subjects.isEmpty ? 'No subjects yet' : 'See All',
                            subtitle: 'Resume your current courses and weekly materials',
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                  if (vm.subjects.isEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: _StudentEmptyState(),
                      ),
                    )
                  else
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 204,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: vm.subjects.length.clamp(0, 5),
                          separatorBuilder: (_, _) => const SizedBox(width: 14),
                          itemBuilder: (context, index) {
                            final subject = vm.subjects[index];
                            return _StudentSubjectCard(subject: subject);
                          },
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 28),
                  ),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: _TodayScheduleCard(),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 28),
                  ),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: DashboardSectionTitle(
                        title: 'Upcoming Deadlines',
                        actionLabel: 'Prioritized',
                        subtitle: 'Stay ahead of the nearest academic deadlines',
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
                    sliver: SliverList.list(
                      children: const [
                        _DeadlineTile(
                          title: 'SRS Document Submission',
                          subtitle: 'Software Engineering',
                          dueLabel: 'Due tomorrow, 11:59 PM',
                          color: Colors.redAccent,
                        ),
                        SizedBox(height: 12),
                        _DeadlineTile(
                          title: 'Quiz Revision: Agile Basics',
                          subtitle: 'Software Engineering',
                          dueLabel: 'Sunday, 10:00 AM',
                          color: Colors.deepPurple,
                        ),
                        SizedBox(height: 12),
                        _DeadlineTile(
                          title: 'Database Lab Sheet',
                          subtitle: 'Database Systems',
                          dueLabel: 'Monday, 2:00 PM',
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StudentHomeViewModel {
  final String userName;
  final List<Subject> subjects;

  const _StudentHomeViewModel({
    required this.userName,
    required this.subjects,
  });

  factory _StudentHomeViewModel.fromStore(Store<AppState> store) {
    final email = store.state.authState.email ?? 'student@tolab.edu';
    final rawName = email.split('@').first;
    final userName = rawName.isEmpty
        ? 'Student'
        : '${rawName[0].toUpperCase()}${rawName.substring(1)}';

    return _StudentHomeViewModel(
      userName: userName,
      subjects: store.state.subjectsState.subjects,
    );
  }
}

class _StudentOverviewCard extends StatelessWidget {
  final String userName;

  const _StudentOverviewCard({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      child: DashboardHeroCard(
        badge: 'Focus Mode',
        badgeIcon: Icons.auto_awesome_rounded,
        title: 'Good progress, $userName',
        description:
            'You are on track this week. Complete the next assignment and review one quiz to keep your streak active.',
        gradient: const [Color(0xFF0E2A47), Color(0xFF225C9C)],
        trailing: const Icon(
          Icons.waving_hand_rounded,
          color: Color(0xFFFFD27A),
        ),
        footer: const [
          HeroMetricChip(value: '84%', label: 'Attendance'),
          HeroMetricChip(value: '3', label: 'Tasks pending'),
          HeroMetricChip(value: '7', label: 'Study streak'),
        ],
      ),
    );
  }
}

class _StudentSubjectCard extends StatelessWidget {
  final Subject subject;

  const _StudentSubjectCard({required this.subject});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 252,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF7FAFF)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5ECF8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Color(0xFF225C9C),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              subject.code,
              style: const TextStyle(
                color: Color(0xFF3469C8),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            subject.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF17212F),
              fontSize: 18,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const Spacer(),
          Text(
            subject.description ?? 'Core study materials and weekly activities.',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF65758B),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              Icon(
                Icons.play_circle_outline_rounded,
                size: 16,
                color: Color(0xFF3469C8),
              ),
              SizedBox(width: 6),
              Text(
                'Open materials',
                style: TextStyle(
                  color: Color(0xFF3469C8),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeadlineTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String dueLabel;
  final Color color;

  const _DeadlineTile({
    required this.title,
    required this.subtitle,
    required this.dueLabel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE6ECF6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0E2A47),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.flag_rounded, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF17212F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF6F7E92),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            dueLabel,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentEmptyState extends StatelessWidget {
  const _StudentEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFE),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE3EAF6)),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.library_books_outlined,
            size: 42,
            color: Color(0xFF3469C8),
          ),
          SizedBox(height: 12),
          Text(
            'Your subjects will appear here once they are loaded.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF17212F),
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyProgressStrip extends StatelessWidget {
  const _DailyProgressStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE3EBF7)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0E2A47),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: const Row(
        children: [
          Expanded(
            child: _ProgressMiniCard(
              icon: Icons.task_alt_rounded,
              title: '4/6 done',
              subtitle: 'Weekly goals',
              color: Colors.green,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _ProgressMiniCard(
              icon: Icons.timer_outlined,
              title: '2h 40m',
              subtitle: 'Study time',
              color: Colors.orange,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _ProgressMiniCard(
              icon: Icons.local_fire_department_rounded,
              title: '7 days',
              subtitle: 'Consistency',
              color: Colors.deepPurple,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressMiniCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _ProgressMiniCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBFF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF17212F),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF6C7C92),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayScheduleCard extends StatelessWidget {
  const _TodayScheduleCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFF6FAFF)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2EAF6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0E2A47),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Today at a Glance',
                  style: TextStyle(
                    color: Color(0xFF17212F),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '3 sessions',
                style: TextStyle(
                  color: Color(0xFF3469C8),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _ScheduleItem(
            time: '09:00',
            title: 'Software Engineering Lecture',
            place: 'Hall A2',
            color: Colors.indigo,
          ),
          SizedBox(height: 12),
          _ScheduleItem(
            time: '12:30',
            title: 'Database Lab',
            place: 'Lab 3',
            color: Colors.teal,
          ),
          SizedBox(height: 12),
          _ScheduleItem(
            time: '03:00',
            title: 'Community Mentoring Session',
            place: 'Online',
            color: Colors.orange,
          ),
        ],
      ),
    );
  }
}

class _ScheduleItem extends StatelessWidget {
  final String time;
  final String title;
  final String place;
  final Color color;

  const _ScheduleItem({
    required this.time,
    required this.title,
    required this.place,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6ECF6)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              time,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF17212F),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  place,
                  style: const TextStyle(
                    color: Color(0xFF6C7C92),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: color),
        ],
      ),
    );
  }
}
