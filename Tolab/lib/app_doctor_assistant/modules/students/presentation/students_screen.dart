import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../../app_admin/shared/widgets/status_badge.dart';
import '../../../core/models/session_user.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../mock/doctor_assistant_mock_repository.dart';
import '../../../mock/mock_portal_models.dart';
import '../../../presentation/widgets/doctor_assistant_shell.dart';
import '../../../presentation/widgets/doctor_assistant_widgets.dart';
import '../../../state/app_state.dart';
import '../../auth/state/session_selectors.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    return StoreConnector<DoctorAssistantAppState, SessionUser?>(
      converter: (store) => getCurrentUser(store.state),
      builder: (context, user) {
        if (user == null) {
          return const SizedBox.shrink();
        }

        final repository = DoctorAssistantMockRepository.instance;
        final allStudents = repository.studentsFor(user);
        final filteredStudents = _filter == 'All'
            ? allStudents
            : allStudents
                  .where((student) => student.riskLabel == _filter)
                  .toList(growable: false);

        return DoctorAssistantShell(
          user: user,
          activeRoute: AppRoutes.students,
          unreadNotifications: repository.unreadNotificationsFor(user),
          child: DoctorAssistantPageScaffold(
            title: 'Students',
            subtitle:
                'Track academic health, engagement, and recent activity with a clean local directory powered by mock records.',
            breadcrumbs: const ['Workspace', 'Students'],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: ['All', 'Healthy', 'Watch', 'High Risk', 'Stable']
                      .map(
                        (filter) => ChoiceChip(
                          label: Text(filter),
                          selected: _filter == filter,
                          onSelected: (_) => setState(() => _filter = filter),
                        ),
                      )
                      .toList(growable: false),
                ),
                const SizedBox(height: AppSpacing.md),
                if (filteredStudents.isEmpty)
                  const DoctorAssistantEmptyState(
                    title: 'No students match this filter',
                    subtitle:
                        'Try another risk segment to view the local student directory.',
                  )
                else
                  Column(
                    children: filteredStudents
                        .map((student) => _StudentCard(student: student))
                        .toList(growable: false),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.student});

  final MockStudentDirectoryEntry student;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: DoctorAssistantItemCard(
        icon: Icons.school_rounded,
        title: student.name,
        subtitle:
            '${student.code} - ${student.subjectCode} / ${student.sectionLabel}',
        meta:
            'Attendance ${student.attendanceRate}% - Avg ${student.averageScore.toStringAsFixed(1)} - Engagement ${student.engagementScore}',
        statusLabel: student.riskLabel,
        trailing: StatusBadge(student.email),
      ),
    );
  }
}
