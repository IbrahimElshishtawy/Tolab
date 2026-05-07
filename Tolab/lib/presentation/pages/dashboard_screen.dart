import 'package:flutter/material.dart';
import 'package:tolab_fci/core/theme/app_theme.dart';
import 'package:tolab_fci/core/utils/responsive_helper.dart';
import 'package:tolab_fci/core/widgets/responsive_widgets.dart';
import 'package:tolab_fci/domain/entities/user_entity.dart';
import 'package:tolab_fci/mock/fixtures/mock_users.dart';
import 'package:tolab_fci/mock/fixtures/mock_courses.dart';
import 'package:tolab_fci/mock/fixtures/mock_students.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late UserEntity currentUser;
  late List<dynamic> courses;
  late List<dynamic> students;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    currentUser = MockUsers.getUserById('user_008');
    courses = MockCourses.getAllCourses();
    students = MockStudents.getAllStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveAppBar(
        title: 'Dashboard',
        actions: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: UserAvatar(
              initials: '${currentUser.firstName[0]}${currentUser.lastName[0]}',
              imageUrl: currentUser.profileImageUrl,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(context),
            const SizedBox(height: AppSpacing.xl),
            _buildStatsSection(context),
            const SizedBox(height: AppSpacing.xl),
            _buildCoursesSection(context),
            const SizedBox(height: AppSpacing.xl),
            _buildStudentsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back, ${currentUser.firstName}!',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Here\'s what\'s happening in your university today.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.lg),
        ResponsiveGrid(
          mobileColumns: 1,
          tabletColumns: 2,
          desktopColumns: 4,
          spacing: AppSpacing.lg,
          children: [
            StatCard(
              label: 'Total Courses',
              value: '${courses.length}',
              icon: Icons.book_outlined,
              iconColor: AppColors.primary,
            ),
            StatCard(
              label: 'Total Students',
              value: '${students.length}',
              icon: Icons.people_outlined,
              iconColor: AppColors.secondary,
            ),
            StatCard(
              label: 'Active Users',
              value: '${MockUsers.getAllUsers().length}',
              icon: Icons.person_outline,
              iconColor: AppColors.accent,
            ),
            StatCard(
              label: 'Departments',
              value: '2',
              icon: Icons.domain_outlined,
              iconColor: AppColors.info,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCoursesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Courses',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            TextButton(
              onPressed: () {},
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        ResponsiveGrid(
          mobileColumns: 1,
          tabletColumns: 2,
          desktopColumns: 3,
          spacing: AppSpacing.lg,
          children: courses.take(6).map((course) {
            return ResponsiveCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          course.code,
                          style: Theme.of(context).textTheme.labelLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          '${course.creditHours}h',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.primary,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    course.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${course.enrolledStudents}/${course.maxStudents}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      LinearProgressIndicator(
                        value: course.enrolledStudents / course.maxStudents,
                        minHeight: 4,
                        backgroundColor: AppColors.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation(
                          course.enrolledStudents >= course.maxStudents
                              ? AppColors.error
                              : AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStudentsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Top Students',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            TextButton(
              onPressed: () {},
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        ...students.take(5).map((student) {
          final user = MockUsers.getUserById(student.userId);
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: ResponsiveCard(
              child: Row(
                children: [
                  UserAvatar(
                    initials: '${user.firstName[0]}${user.lastName[0]}',
                    imageUrl: user.profileImageUrl,
                    size: 48,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'GPA: ${student.gpa.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryLight,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Text(
                      'Year ${student.academicYear}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.secondary,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
