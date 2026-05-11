import 'package:flutter/material.dart';
import 'package:tolab_fci/core/theme/app_theme.dart';
import 'package:tolab_fci/core/utils/responsive_helper.dart';
import 'package:tolab_fci/core/widgets/responsive_widgets.dart';
import 'package:tolab_fci/domain/entities/course_entity.dart';
import 'package:tolab_fci/mock/fixtures/mock_courses.dart';
import 'package:tolab_fci/mock/fixtures/mock_users.dart';

class CoursesListScreen extends StatefulWidget {
  const CoursesListScreen({super.key});

  @override
  State<CoursesListScreen> createState() => _CoursesListScreenState();
}

class _CoursesListScreenState extends State<CoursesListScreen> {
  late List<CourseEntity> courses;
  late List<CourseEntity> filteredCourses;
  String _searchQuery = '';
  String? _selectedDepartment;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  void _loadCourses() {
    courses = MockCourses.getAllCourses();
    _applyFilters();
  }

  void _applyFilters() {
    filteredCourses = courses.where((course) {
      final matchesSearch =
          course.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          course.code.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesDept =
          _selectedDepartment == null ||
          course.departmentId == _selectedDepartment;
      return matchesSearch && matchesDept;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveAppBar(
        title: 'Courses',
        actions: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Add Course'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchAndFilters(context),
            const SizedBox(height: AppSpacing.xl),
            _buildCoursesList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Manage Courses',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.lg),
        ResponsiveLayout(
          mobile: Column(
            children: [
              _buildSearchField(),
              const SizedBox(height: AppSpacing.md),
              _buildDepartmentFilter(),
            ],
          ),
          tablet: Row(
            children: [
              Expanded(child: _buildSearchField()),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _buildDepartmentFilter()),
            ],
          ),
          desktop: Row(
            children: [
              Expanded(flex: 2, child: _buildSearchField()),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _buildDepartmentFilter()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
          _applyFilters();
        });
      },
      decoration: InputDecoration(
        hintText: 'Search by course name or code...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _applyFilters();
                  });
                },
              )
            : null,
      ),
    );
  }

  Widget _buildDepartmentFilter() {
    final departments = {
      'dept_001': 'Computer Science',
      'dept_002': 'Mathematics',
    };

    return DropdownButtonFormField<String?>(
      initialValue: _selectedDepartment,
      decoration: const InputDecoration(labelText: 'Filter by Department'),
      items: [
        const DropdownMenuItem(value: null, child: Text('All Departments')),
        ...departments.entries.map(
          (entry) =>
              DropdownMenuItem(value: entry.key, child: Text(entry.value)),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _selectedDepartment = value;
          _applyFilters();
        });
      },
    );
  }

  Widget _buildCoursesList(BuildContext context) {
    if (filteredCourses.isEmpty) {
      return EmptyState(
        icon: Icons.menu_book,
        title: 'No courses found',
        subtitle: 'Try adjusting your search or filters',
      );
    }

    return ResponsiveLayout(
      mobile: _buildMobileList(),
      tablet: _buildTabletList(context),
      desktop: _buildDesktopTable(context),
    );
  }

  Widget _buildMobileList() {
    return Column(
      children: filteredCourses.map((course) {
        final instructor = MockUsers.getUserById(course.instructorId);
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: ResponsiveCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.code,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(color: AppColors.primary),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            course.name,
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(AppRadius.md),
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
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    UserAvatar(
                      initials:
                          '${instructor.firstName[0]}${instructor.lastName[0]}',
                      imageUrl: instructor.profileImageUrl,
                      size: 32,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        instructor.fullName,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${course.enrolledStudents}/${course.maxStudents}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        child: LinearProgressIndicator(
                          value: course.enrolledStudents / course.maxStudents,
                          minHeight: 4,
                          backgroundColor: AppColors.surfaceVariant,
                          valueColor: AlwaysStoppedAnimation(
                            course.isFull ? AppColors.error : AppColors.success,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTabletList(BuildContext context) {
    return Column(
      children: filteredCourses.map((course) {
        final instructor = MockUsers.getUserById(course.instructorId);
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: ResponsiveCard(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.code,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        course.name,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Row(
                    children: [
                      UserAvatar(
                        initials:
                            '${instructor.firstName[0]}${instructor.lastName[0]}',
                        imageUrl: instructor.profileImageUrl,
                        size: 32,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          instructor.fullName,
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    '${course.enrolledStudents}/${course.maxStudents}',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDesktopTable(BuildContext context) {
    return ResponsiveCard(
      padding: EdgeInsets.zero,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Code')),
            DataColumn(label: Text('Course Name')),
            DataColumn(label: Text('Instructor')),
            DataColumn(label: Text('Credits')),
            DataColumn(label: Text('Enrollment')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: filteredCourses.map((course) {
            final instructor = MockUsers.getUserById(course.instructorId);
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    course.code,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                DataCell(Text(course.name)),
                DataCell(
                  Row(
                    children: [
                      UserAvatar(
                        initials:
                            '${instructor.firstName[0]}${instructor.lastName[0]}',
                        imageUrl: instructor.profileImageUrl,
                        size: 32,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(instructor.fullName),
                    ],
                  ),
                ),
                DataCell(Text('${course.creditHours}h')),
                DataCell(
                  Text('${course.enrolledStudents}/${course.maxStudents}'),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: course.isFull
                          ? AppColors.error.withValues(alpha: 0.1)
                          : AppColors.secondaryLight,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Text(
                      course.isFull ? 'Full' : 'Available',
                      style: TextStyle(
                        color: course.isFull
                            ? AppColors.error
                            : AppColors.secondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 18),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
