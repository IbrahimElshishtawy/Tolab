import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../core/models/session_user.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../mock/doctor_assistant_mock_repository.dart';
import '../../../presentation/widgets/doctor_assistant_shell.dart';
import '../../../presentation/widgets/doctor_assistant_widgets.dart';
import '../../../presentation/widgets/workspace/faculty_quick_actions_bar.dart';
import '../../../state/app_state.dart';
import '../../auth/state/session_selectors.dart';
import 'models/student_workspace_models.dart';
import 'widgets/student_details_sheet.dart';
import 'widgets/student_row_card.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  String _searchQuery = '';
  String _riskFilter = 'All';
  String _attendanceFilter = 'All';
  String _scoreFilter = 'All';
  String _engagementFilter = 'All';
  final Set<String> _selectedStudentCodes = <String>{};
  final Set<String> _flaggedStudentCodes = <String>{};
  final Map<String, List<String>> _notesByStudentCode = <String, List<String>>{};

  void _toggleSelected(String code) {
    setState(() {
      if (_selectedStudentCodes.contains(code)) {
        _selectedStudentCodes.remove(code);
      } else {
        _selectedStudentCodes.add(code);
      }
    });
  }

  void _addNote(String studentCode, String note) {
    if (note.trim().isEmpty) {
      return;
    }
    setState(() {
      _notesByStudentCode.update(
        studentCode,
        (value) => [...value, note.trim()],
        ifAbsent: () => [note.trim()],
      );
    });
  }

  Future<void> _openNoteDialog(String studentCode) async {
    final controller = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add academic note'),
          content: TextField(
            controller: controller,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Example: missed two quizzes and asked for follow-up in office hours.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (note != null) {
      _addNote(studentCode, note);
    }
  }

  void _openStudentDetails(
    DoctorAssistantMockRepository repository,
    SessionUser user,
    StudentWorkspaceItem student,
  ) {
    final details = buildStudentDetails(repository, user, student);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return StudentDetailsSheet(
          data: details,
          onSendMessage: () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(this.context).showSnackBar(
              SnackBar(content: Text('Message draft prepared for ${student.name}.')),
            );
          },
          onAddNote: () async {
            Navigator.of(context).pop();
            await _openNoteDialog(student.code);
          },
          onFlagStudent: () {
            setState(() {
              if (_flaggedStudentCodes.contains(student.code)) {
                _flaggedStudentCodes.remove(student.code);
              } else {
                _flaggedStudentCodes.add(student.code);
              }
            });
            Navigator.of(context).pop();
          },
          onViewPerformance: () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(this.context).showSnackBar(
              SnackBar(content: Text('Performance view focused on ${student.name}.')),
            );
          },
          onViewAttendance: () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(this.context).showSnackBar(
              SnackBar(content: Text('Attendance ledger opened for ${student.name}.')),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<DoctorAssistantAppState, SessionUser?>(
      converter: (store) => getCurrentUser(store.state),
      builder: (context, user) {
        if (user == null) {
          return const SizedBox.shrink();
        }

        final repository = DoctorAssistantMockRepository.instance;
        final workspace = buildStudentsWorkspace(
          repository,
          user,
          notesByStudentCode: _notesByStudentCode,
          flaggedStudentCodes: _flaggedStudentCodes,
        );
        final filteredStudents = filterStudentsWorkspace(
          workspace.students,
          searchQuery: _searchQuery,
          riskFilter: _riskFilter,
          attendanceFilter: _attendanceFilter,
          scoreFilter: _scoreFilter,
          engagementFilter: _engagementFilter,
        );

        return DoctorAssistantShell(
          user: user,
          activeRoute: AppRoutes.students,
          unreadNotifications: repository.unreadNotificationsFor(user),
          child: DoctorAssistantPageScaffold(
            title: 'Students',
            subtitle:
                'Student management workspace for academic follow-up, bulk reminders, and risk-aware intervention.',
            breadcrumbs: const ['Workspace', 'Students'],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FacultyQuickActionsBar(user: user),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: workspace.summary
                      .map(
                        (item) => Container(
                          width: 220,
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: item.color.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: item.color.withValues(alpha: 0.18)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(item.icon, color: item.color),
                              const SizedBox(height: AppSpacing.sm),
                              Text(item.label, style: Theme.of(context).textTheme.bodySmall),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                item.value,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
                const SizedBox(height: AppSpacing.md),
                DoctorAssistantPanel(
                  title: 'Student filters',
                  subtitle:
                      'Filter the roster by attendance, score, risk, and engagement before taking action.',
                  child: Column(
                    children: [
                      TextField(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search_rounded),
                          hintText: 'Search by name, code, or subject',
                        ),
                        onChanged: (value) => setState(() => _searchQuery = value),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: ['All', 'Healthy', 'Watch', 'High Risk', 'Stable']
                            .map(
                              (filter) => ChoiceChip(
                                label: Text(filter),
                                selected: _riskFilter == filter,
                                onSelected: (_) => setState(() => _riskFilter = filter),
                              ),
                            )
                            .toList(growable: false),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          _FilterButton(
                            label: 'Attendance: $_attendanceFilter',
                            onPressed: () => _showFilterMenu(
                              context,
                              const ['All', 'Below 80%', '80%+'],
                              _attendanceFilter,
                              (value) => setState(() => _attendanceFilter = value),
                            ),
                          ),
                          _FilterButton(
                            label: 'Score: $_scoreFilter',
                            onPressed: () => _showFilterMenu(
                              context,
                              const ['All', 'Below 60', '60 - 79', '80+'],
                              _scoreFilter,
                              (value) => setState(() => _scoreFilter = value),
                            ),
                          ),
                          _FilterButton(
                            label: 'Engagement: $_engagementFilter',
                            onPressed: () => _showFilterMenu(
                              context,
                              const ['All', 'Below 60', '60+'],
                              _engagementFilter,
                              (value) => setState(() => _engagementFilter = value),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (_selectedStudentCodes.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  DoctorAssistantPanel(
                    title: 'Bulk actions',
                    subtitle:
                        '${_selectedStudentCodes.length} students selected for reminder, export, note assignment, or direct notification.',
                    child: Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        FilledButton.tonalIcon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Reminder prepared for ${_selectedStudentCodes.length} students.')),
                            );
                          },
                          icon: const Icon(Icons.notifications_active_rounded),
                          label: const Text('Send reminder'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Export list generated for ${_selectedStudentCodes.length} selected students.')),
                            );
                          },
                          icon: const Icon(Icons.download_rounded),
                          label: const Text('Export list'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: () async {
                            for (final code in _selectedStudentCodes) {
                              _addNote(code, 'Bulk note assigned on 23 Apr for follow-up.');
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Academic note assigned to selected students.')),
                            );
                          },
                          icon: const Icon(Icons.note_add_rounded),
                          label: const Text('Assign note'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Notification queued for ${_selectedStudentCodes.length} students.')),
                            );
                          },
                          icon: const Icon(Icons.campaign_rounded),
                          label: const Text('Notify selected'),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                if (filteredStudents.isEmpty)
                  const DoctorAssistantEmptyState(
                    title: 'No students match the current filters',
                    subtitle:
                        'Adjust attendance, score, risk, or engagement filters to reopen the monitored roster.',
                  )
                else
                  Column(
                    children: filteredStudents
                        .map(
                          (student) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: StudentRowCard(
                              student: student,
                              selected: _selectedStudentCodes.contains(student.code),
                              onToggleSelected: () => _toggleSelected(student.code),
                              onOpenDetails: () => _openStudentDetails(repository, user, student),
                            ),
                          ),
                        )
                        .toList(growable: false),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showFilterMenu(
    BuildContext context,
    List<String> values,
    String selected,
    ValueChanged<String> onSelected,
  ) async {
    final value = await showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(100, 180, 100, 100),
      items: values
          .map(
            (item) => PopupMenuItem<String>(
              value: item,
              child: Text(item),
            ),
          )
          .toList(growable: false),
    );
    if (value != null && value != selected) {
      onSelected(value);
    }
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.filter_list_rounded),
      label: Text(label),
    );
  }
}
