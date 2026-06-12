import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../../app/auth/state/auth_controller.dart';
import '../../../../app/core/app_scope.dart';
import '../../../../app/localization/app_localizations.dart';
import '../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../../app_admin/core/widgets/app_card.dart';
import '../../../../app_admin/shared/widgets/premium_button.dart';
import '../../../../app_admin/shared/widgets/status_badge.dart';
import '../../../../app_doctor_assistant/mock/doctor_assistant_mock_repository.dart';
import '../../../../app_doctor_assistant/core/models/notification_models.dart';
import '../../../../app_doctor_assistant/modules/results/models/results_models.dart';
import '../../../../app_doctor_assistant/presentation/widgets/doctor_assistant_shell.dart';
import '../../../../app_doctor_assistant/presentation/widgets/doctor_assistant_widgets.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  bool _loading = true;
  String? _error;
  
  // Local state for loaded student view model
  late String _studentName;
  late String _studentCode;
  late String _department;
  late double _gpa;
  late int _attendanceRate;
  late List<_StudentSubjectDetail> _subjects = [];

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  void _loadStudentData() async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      
      final mockRepo = DoctorAssistantMockRepository.instance;
      // We know our student is Menna Adel with code 20230041
      _studentName = 'Menna Adel';
      _studentCode = '20230041';
      _department = 'Computer Science';
      _gpa = 3.9;
      _attendanceRate = 96;

      final allSubjects = mockRepo.subjectsFor(mockRepo.userByEmail('doctor@tolab.edu'));
      final List<_StudentSubjectDetail> loaded = [];

      for (final subject in allSubjects) {
        // Fetch results for this subject
        final results = mockRepo.subjectResultsById(subject.id, mockRepo.userByEmail('doctor@tolab.edu'));
        
        // Find Menna's row
        final studentRow = results.students.firstWhere(
          (row) => row.studentCode == _studentCode,
          orElse: () => GradeStudentRowModel(
            studentId: 0,
            studentName: _studentName,
            studentCode: _studentCode,
            statusLabel: 'Pending',
            entries: const {},
          ),
        );

        final categoriesList = results.categories.map((category) {
          final entry = studentRow.entries[category.key];
          final hasPublishedGrade = entry?.statusLabel.toLowerCase() == 'published';
          
          return _StudentGradeItem(
            categoryLabel: category.label,
            score: hasPublishedGrade ? entry?.score : null,
            maxScore: category.maxScore,
            status: entry?.statusLabel ?? 'Pending',
          );
        }).toList();

        // Get uploaded sheets for this subject
        final sheets = results.uploadedSheets;

        loaded.add(_StudentSubjectDetail(
          subjectId: subject.id,
          subjectCode: subject.code,
          subjectName: subject.name,
          instructorName: subject.department == 'Computer Science'
              ? 'Dr. Salma Hassan'
              : subject.department == 'Information Systems'
                  ? 'Dr. Khaled Mostafa'
                  : 'Dr. Hala Ezz',
          grades: categoriesList,
          files: sheets,
        ));
      }

      if (mounted) {
        setState(() {
          _subjects = loaded;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = AppScope.auth(context);
    final user = authController.state.user!;

    return DoctorAssistantShell(
      user: user.toSessionUser(),
      activeRoute: '/student/dashboard',
      unreadNotifications: 0,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWelcomeHeader(context),
                        const SizedBox(height: AppSpacing.md),
                        _buildStatsRow(context),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          context.l10n.byValue('Subjects & Grades'),
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ..._subjects.map((subj) => _buildSubjectCard(context, subj)),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            child: Text(
              _studentName.substring(0, 2).toUpperCase(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${context.l10n.byValue('Welcome back')}, $_studentName',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '${context.l10n.byValue('Student Code')}: $_studentCode · $_department',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 600 ? 3 : 1;
        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            _buildStatCard(
              context,
              title: context.l10n.byValue('Cumulative GPA'),
              value: _gpa.toStringAsFixed(2),
              icon: Icons.grade_rounded,
              color: Colors.blue,
              width: columns == 3 ? (constraints.maxWidth - AppSpacing.md * 2) / 3 : constraints.maxWidth,
            ),
            _buildStatCard(
              context,
              title: context.l10n.byValue('Attendance Rate'),
              value: '$_attendanceRate%',
              icon: Icons.check_circle_outline_rounded,
              color: Colors.green,
              width: columns == 3 ? (constraints.maxWidth - AppSpacing.md * 2) / 3 : constraints.maxWidth,
            ),
            _buildStatCard(
              context,
              title: context.l10n.byValue('Enrolled Subjects'),
              value: '${_subjects.length}',
              icon: Icons.book_rounded,
              color: Colors.purple,
              width: columns == 3 ? (constraints.maxWidth - AppSpacing.md * 2) / 3 : constraints.maxWidth,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required double width,
  }) {
    return SizedBox(
      width: width,
      child: AppCard(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodySmall),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectCard(BuildContext context, _StudentSubjectDetail subject) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${subject.subjectCode} · ${context.l10n.byValue(subject.subjectName)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        subject.instructorName,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                StatusBadge('Active'),
              ],
            ),
            const Divider(height: AppSpacing.lg),
            Text(
              context.l10n.byValue('Academic Grades'),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...subject.grades.map((grade) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.l10n.byValue(grade.categoryLabel),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    if (grade.score != null)
                      Text(
                        '${grade.score!.toStringAsFixed(1)} / ${grade.maxScore.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )
                    else
                      Text(
                        context.l10n.byValue('Pending'),
                        style: TextStyle(
                          color: Theme.of(context).disabledColor,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    const SizedBox(width: AppSpacing.sm),
                    StatusBadge(grade.score != null ? 'Published' : 'Draft'),
                  ],
                ),
              );
            }),
            if (subject.files.isNotEmpty) ...[
              const Divider(height: AppSpacing.lg),
              Text(
                context.l10n.byValue('Shared Files'),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...subject.files.map((file) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Row(
                    children: [
                      const Icon(Icons.insert_drive_file_outlined, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              file.name,
                              style: Theme.of(context).textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${file.mimeType} · ${file.sizeLabel}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      PremiumButton(
                        label: context.l10n.byValue('Download'),
                        icon: Icons.download_rounded,
                        isSecondary: true,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${context.l10n.byValue('Downloading')} ${file.name}...',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

class _StudentSubjectDetail {
  _StudentSubjectDetail({
    required this.subjectId,
    required this.subjectCode,
    required this.subjectName,
    required this.instructorName,
    required this.grades,
    required this.files,
  });

  final int subjectId;
  final String subjectCode;
  final String subjectName;
  final String instructorName;
  final List<_StudentGradeItem> grades;
  final List<UploadModel> files;
}

class _StudentGradeItem {
  _StudentGradeItem({
    required this.categoryLabel,
    required this.score,
    required this.maxScore,
    required this.status,
  });

  final String categoryLabel;
  final double? score;
  final double maxScore;
  final String status;
}
