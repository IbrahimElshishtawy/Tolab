import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:tolab_fci/features/home/presentation/widgets/dashboard_shell.dart';
import 'package:tolab_fci/features/home/presentation/widgets/home_header.dart';
import 'package:tolab_fci/features/home/presentation/widgets/quick_action_card.dart';
import 'package:tolab_fci/features/home/presentation/widgets/search_bar_widget.dart';
import 'package:tolab_fci/features/subjects/data/models.dart';
import 'package:tolab_fci/features/subjects/redux/subjects_actions.dart';
import 'package:tolab_fci/redux/app_state.dart';

import 'student_deadline_tile.dart';
import 'student_empty_state.dart';
import 'student_overview_card.dart';
import 'student_progress_strip.dart';
import 'student_subject_card.dart';
import 'student_today_schedule_card.dart';

class StudentHomeContent extends StatelessWidget {
  const StudentHomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, StudentHomeViewModel>(
      onInit: (store) => store.dispatch(FetchSubjectsAction()),
      converter: StudentHomeViewModel.fromStore,
      builder: (context, vm) {
        return DashboardShell(
          topBackground: const Stack(
            children: [
              DashboardOrb(
                size: 220,
                top: -100,
                right: -30,
                colors: [Color(0xFFCADFFF), Color(0xFF8EB6FF)],
              ),
              DashboardOrb(
                size: 180,
                top: 220,
                left: -70,
                colors: [Color(0xFFE7F0FF), Color(0xFFB7D0FF)],
              ),
            ],
          ),
          child: CustomScrollView(
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
                      child: StudentOverviewCard(userName: vm.userName),
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: StudentProgressStrip(),
                    ),
                    const SizedBox(height: 28),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
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
                        subtitle:
                            'Resume your current courses and weekly materials',
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
                    child: StudentEmptyState(),
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
                        return StudentSubjectCard(subject: subject);
                      },
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 28)),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: StudentTodayScheduleCard(),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 28)),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: DashboardSectionTitle(
                    title: 'Upcoming Deadlines',
                    actionLabel: 'Prioritized',
                    subtitle:
                        'Stay ahead of the nearest academic deadlines',
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
                sliver: SliverList.list(
                  children: const [
                    StudentDeadlineTile(
                      title: 'SRS Document Submission',
                      subtitle: 'Software Engineering',
                      dueLabel: 'Due tomorrow, 11:59 PM',
                      color: Colors.redAccent,
                    ),
                    SizedBox(height: 12),
                    StudentDeadlineTile(
                      title: 'Quiz Revision: Agile Basics',
                      subtitle: 'Software Engineering',
                      dueLabel: 'Sunday, 10:00 AM',
                      color: Colors.deepPurple,
                    ),
                    SizedBox(height: 12),
                    StudentDeadlineTile(
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
        );
      },
    );
  }
}

class StudentHomeViewModel {
  final String userName;
  final List<Subject> subjects;

  const StudentHomeViewModel({
    required this.userName,
    required this.subjects,
  });

  factory StudentHomeViewModel.fromStore(Store<AppState> store) {
    final email = store.state.authState.email ?? 'student@tolab.edu';
    final rawName = email.split('@').first;
    final userName = rawName.isEmpty
        ? 'Student'
        : '${rawName[0].toUpperCase()}${rawName.substring(1)}';

    return StudentHomeViewModel(
      userName: userName,
      subjects: store.state.subjectsState.subjects,
    );
  }
}
