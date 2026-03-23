import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:tolab_fci/features/home/presentation/widgets/course_card.dart';
import 'package:tolab_fci/features/home/presentation/widgets/dashboard_shell.dart';
import 'package:tolab_fci/features/home/presentation/widgets/home_header.dart';
import 'package:tolab_fci/features/home/presentation/widgets/quick_action_card.dart';
import 'package:tolab_fci/features/home/presentation/widgets/search_bar_widget.dart';
import 'package:tolab_fci/redux/app_state.dart';

import 'doctor_timeline_panel.dart';

class DoctorHomeContent extends StatelessWidget {
  const DoctorHomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, String?>(
      converter: (store) => store.state.authState.email,
      builder: (context, email) {
        final userName = email?.split('@').first ?? 'Doctor';

        return DashboardShell(
          topBackground: const Stack(
            children: [
              DashboardOrb(
                size: 220,
                top: -90,
                right: -20,
                colors: [Color(0xFFD4E5FF), Color(0xFF8EB8FF)],
              ),
              DashboardOrb(
                size: 170,
                top: 200,
                left: -60,
                colors: [Color(0xFFEAF1FF), Color(0xFFC6DBFF)],
              ),
            ],
          ),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    HomeHeader(
                      userName: 'Dr. ${userName.toUpperCase()}',
                      role: 'Professor',
                    ),
                    const SearchBarWidget(
                      hintText: 'Search subjects, students, or reports...',
                    ),
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: DashboardHeroCard(
                        badge: 'Faculty Overview',
                        badgeIcon: Icons.workspace_premium_rounded,
                        title: 'Your teaching pipeline is on track',
                        description:
                            'Review active courses, publish updates, and monitor academic performance from a single faculty dashboard.',
                        gradient: const [Color(0xFF102B46), Color(0xFF235E98)],
                        trailing: const Icon(
                          Icons.auto_graph_rounded,
                          color: Color(0xFFFFD27A),
                        ),
                        footer: const [
                          HeroMetricChip(value: '3', label: 'Active courses'),
                          HeroMetricChip(value: '120', label: 'Students'),
                          HeroMetricChip(value: '12', label: 'Open tasks'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: DashboardSectionTitle(
                        title: 'My Courses',
                        actionLabel: 'See All',
                        subtitle:
                            'Access current subjects, materials, and course activity',
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
                        courseName: 'Software Engineering',
                        courseCode: 'CS311',
                        studentsCount: '120 Students',
                        onTap: () {},
                      ),
                      CourseCard(
                        courseName: 'Database Systems',
                        courseCode: 'IS212',
                        studentsCount: '85 Students',
                        onTap: () {},
                      ),
                      CourseCard(
                        courseName: 'Operating Systems',
                        courseCode: 'CS221',
                        studentsCount: '110 Students',
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
                    title: 'Doctor Actions',
                    actionLabel: 'Manage',
                    subtitle: 'Daily academic controls and content workflow',
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
                        title: 'Post\nAnnouncement',
                        icon: Icons.campaign_outlined,
                        color: Colors.orange,
                        onTap: () {},
                      ),
                      QuickActionCard(
                        title: 'Upload\nMaterials',
                        icon: Icons.upload_file_outlined,
                        color: Colors.blue,
                        onTap: () {},
                      ),
                      QuickActionCard(
                        title: 'View\nGrades',
                        icon: Icons.assignment_turned_in_outlined,
                        color: Colors.green,
                        onTap: () {},
                      ),
                      QuickActionCard(
                        title: 'Attendance\nSessions',
                        icon: Icons.how_to_reg_outlined,
                        color: Colors.purple,
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
                  child: DoctorTimelinePanel(),
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
