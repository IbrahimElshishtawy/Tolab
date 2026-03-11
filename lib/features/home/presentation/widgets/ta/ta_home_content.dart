import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:tolab_fci/features/home/presentation/widgets/course_card.dart';
import 'package:tolab_fci/features/home/presentation/widgets/dashboard_shell.dart';
import 'package:tolab_fci/features/home/presentation/widgets/home_header.dart';
import 'package:tolab_fci/features/home/presentation/widgets/quick_action_card.dart';
import 'package:tolab_fci/features/home/presentation/widgets/search_bar_widget.dart';
import 'package:tolab_fci/redux/app_state.dart';

import 'ta_queue_panel.dart';

class TaHomeContent extends StatelessWidget {
  const TaHomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, String?>(
      converter: (store) => store.state.authState.email,
      builder: (context, email) {
        final userName = email?.split('@').first ?? 'TA';

        return DashboardShell(
          topBackground: const Stack(
            children: [
              DashboardOrb(
                size: 220,
                top: -90,
                right: -20,
                colors: [Color(0xFFD7F1F0), Color(0xFF9ED8D4)],
              ),
              DashboardOrb(
                size: 170,
                top: 210,
                left: -60,
                colors: [Color(0xFFE9FBFA), Color(0xFFC4EEEA)],
              ),
            ],
          ),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    HomeHeader(
                      userName: userName.toUpperCase(),
                      role: 'Teaching Assistant',
                    ),
                    const SearchBarWidget(
                      hintText: 'Search labs, submissions, or students...',
                    ),
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: DashboardHeroCard(
                        badge: 'Lab Control Center',
                        badgeIcon: Icons.science_rounded,
                        title: 'Manage practical sessions with clarity',
                        description:
                            'Track lab groups, monitor student questions, and keep assignments moving across every section.',
                        gradient: const [Color(0xFF0F3E40), Color(0xFF157B77)],
                        trailing: const Icon(
                          Icons.school_rounded,
                          color: Color(0xFFFFE08D),
                        ),
                        footer: const [
                          HeroMetricChip(value: '2', label: 'Labs today'),
                          HeroMetricChip(value: '55', label: 'Students'),
                          HeroMetricChip(value: '9', label: 'To grade'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: DashboardSectionTitle(
                        title: 'Upcoming Lab Sessions',
                        actionLabel: 'This Week',
                        subtitle:
                            'Current sections and practical groups under your supervision',
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 186,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      CourseCard(
                        courseName: 'Intro to Programming Lab',
                        courseCode: 'CS101 - Lab',
                        studentsCount: '30 Students',
                        onTap: () {},
                      ),
                      CourseCard(
                        courseName: 'Data Structures Lab',
                        courseCode: 'CS201 - Lab',
                        studentsCount: '25 Students',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 28)),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: DashboardSectionTitle(
                    title: 'TA Dashboard',
                    actionLabel: 'Manage',
                    subtitle:
                        'Fast access to grading, follow-up, and lab operations',
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.18,
                    children: [
                      QuickActionCard(
                        title: 'Grade\nAssignments',
                        icon: Icons.grade_outlined,
                        color: Colors.teal,
                        onTap: () {},
                      ),
                      QuickActionCard(
                        title: 'Student\nQueries',
                        icon: Icons.question_answer_outlined,
                        color: Colors.indigo,
                        onTap: () {},
                      ),
                      QuickActionCard(
                        title: 'Lab\nAttendance',
                        icon: Icons.playlist_add_check_outlined,
                        color: Colors.deepOrange,
                        onTap: () {},
                      ),
                      QuickActionCard(
                        title: 'Office\nHours',
                        icon: Icons.event_available_outlined,
                        color: Colors.brown,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 28)),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: TaQueuePanel(),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 28)),
            ],
          ),
        );
      },
    );
  }
}
