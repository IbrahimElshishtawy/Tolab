import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../shared/forms/app_dropdown_field.dart';
import '../../../shared/forms/app_text_field.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../core/animations/app_motion.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/responsive/app_breakpoints.dart';
import '../../../core/spacing/app_spacing.dart';
import '../../../shared/models/schedule_models.dart';
import '../models/section_management_models.dart';
import 'design/section_management_tokens.dart';
import 'widgets/section_overview_tab.dart';
import 'widgets/section_schedule_tab.dart';
import 'widgets/section_staff_tab.dart';
import 'widgets/section_students_tab.dart';
import 'widgets/section_subjects_tab.dart';
import 'widgets/section_desktop_sidebar.dart';
import 'widgets/sections_mock_data.dart';
import 'widgets/section_hero_header.dart';
import 'widgets/section_portfolio_strip.dart';
import 'widgets/section_tab_bar.dart';

class SectionsScreen extends StatefulWidget {
  const SectionsScreen({super.key});

  @override
  State<SectionsScreen> createState() => _SectionsScreenState();
}

class _SectionsScreenState extends State<SectionsScreen> {
  late List<SectionManagementRecord> _records;
  late SectionManagementRecord _selectedRecord;
  late DateTime _selectedDay;

  SectionDetailTab _activeTab = SectionDetailTab.overview;
  SectionScheduleViewMode _scheduleViewMode = SectionScheduleViewMode.week;

  @override
  void initState() {
    super.initState();
    _records = buildMockSections();
    _selectedRecord = _records.first;
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final deviceType = AppBreakpoints.resolve(context);
    final isDesktop = deviceType == DeviceScreenType.desktop;
    final isTablet = deviceType == DeviceScreenType.tablet;
    final horizontalPadding = isDesktop
        ? AppSpacing.xxxl
        : isTablet
            ? AppSpacing.xl
            : AppSpacing.md;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: SectionManagementPalette.pageGradient(context),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -80,
            child: SectionBackdropOrb(
              size: 280,
              color: SectionManagementPalette.orbPrimary(context),
            ),
          ),
          Positioned(
            top: 280,
            left: -100,
            child: SectionBackdropOrb(
              size: 240,
              color: SectionManagementPalette.orbSuccess(context),
            ),
          ),
          Positioned(
            bottom: -120,
            right: 160,
            child: SectionBackdropOrb(
              size: 260,
              color: SectionManagementPalette.orbWarning(context),
            ),
          ),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                AppSpacing.xl,
                horizontalPadding,
                AppSpacing.xxxl,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppConstants.shellMaxContentWidth,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final showSidebarPreview = constraints.maxWidth >= 1560;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionHeroHeader(
                            record: _selectedRecord,
                            compact: constraints.maxWidth < 900,
                            onEdit: () => _showSnack(
                              'Edit panel is ready for form wiring to the real section editor.',
                            ),
                            onDelete: () => _showSnack(
                              'Delete action is intentionally mocked to protect the sample data.',
                            ),
                            onToggleActivation: _toggleSectionActivation,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          SectionPortfolioStrip(
                            records: _records,
                            selectedRecord: _selectedRecord,
                            onSelectRecord: _selectRecord,
                            onAddSection: () => _showAddSectionDialog(context),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          SectionTabBar(
                            activeTab: _activeTab,
                            onTabChanged: (tab) =>
                                setState(() => _activeTab = tab),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          if (showSidebarPreview)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildMainWorkspace(context)),
                                const SizedBox(width: AppSpacing.xl),
                                SizedBox(
                                  width: 288,
                                  child: _buildDesktopSidebar(context),
                                ),
                              ],
                            )
                          else
                            _buildMainWorkspace(context),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildMainWorkspace(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.medium,
      switchInCurve: AppMotion.entrance,
      switchOutCurve: AppMotion.emphasized,
      child: Container(
        key: ValueKey<String>(_activeTab.name),
        child: switch (_activeTab) {
          SectionDetailTab.overview => SectionOverviewTab(
              record: _selectedRecord,
              visibleAlerts: _buildVisibleAlerts(_selectedRecord),
              snapshots: _sectionSnapshots(),
            ),
          SectionDetailTab.students => SectionStudentsTab(
              selectedRecord: _selectedRecord,
              siblingRecords:
                  _records.where((r) => r.id != _selectedRecord.id).toList(),
              onMoveStudents: _moveStudents,
              onRemoveStudents: (studentIds) {
                final updated = _selectedRecord.copyWith(
                  students: _selectedRecord.students
                      .where((student) => !studentIds.contains(student.id))
                      .toList(),
                );
                final removedCount = studentIds.length;
                _replaceRecord(updated);
                _showSnack(
                    '$removedCount students were removed from ${updated.code}.');
              },
              onAddStudent: () => _showSnack(
                'Add student action is prepared for roster import or live search integration.',
              ),
              showSnack: _showSnack,
            ),
          SectionDetailTab.schedule => SectionScheduleTab(
              selectedDay: _selectedDay,
              viewMode: _scheduleViewMode,
              visibleDays: _visibleScheduleDays(),
              dayEvents: _eventsForDay(_selectedDay),
              eventsByDay: {
                for (final day in _visibleScheduleDays())
                  day: _eventsForDay(day),
              },
              onDaySelected: (day) => setState(() => _selectedDay = day),
              onViewModeChanged: (mode) =>
                  setState(() => _scheduleViewMode = mode),
            ),
          SectionDetailTab.subjects => SectionSubjectsTab(
              subjects: _selectedRecord.subjects,
              onAssignSubject: () => _showSnack(
                'Assign subject flow is ready for API-backed search and attach behavior.',
              ),
            ),
          SectionDetailTab.staff => SectionStaffTab(
              staff: _selectedRecord.staff,
              onAssignStaff: () => _showSnack(
                'Assign staff flow is staged for directory search integration.',
              ),
              onAssignMember: (member) => _showSnack(
                '${member.name} assignment control is in preview mode.',
              ),
              onUnassignMember: (member) => _showSnack(
                '${member.name} unassign confirmation is ready for backend wiring.',
              ),
            ),
        },
      ),
    );
  }

  Widget _buildDesktopSidebar(BuildContext context) {
    final visibleAlerts = _buildVisibleAlerts(_selectedRecord);
    final previewEvents = _eventsForDay(_selectedDay).take(3).toList();

    return SectionDesktopSidebar(
      selectedRecord: _selectedRecord,
      records: _records,
      activeTab: _activeTab,
      visibleAlerts: visibleAlerts,
      previewEvents: previewEvents,
    );
  }

  DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  DateTime _startOfWeek(DateTime date) {
    final normalized = _dateOnly(date);
    return normalized.subtract(Duration(days: normalized.weekday - 1));
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<DateTime> _visibleScheduleDays() {
    if (_scheduleViewMode == SectionScheduleViewMode.day) {
      return [_dateOnly(_selectedDay)];
    }

    final start = _startOfWeek(_selectedDay);
    return List<DateTime>.generate(
      5,
      (index) => start.add(Duration(days: index)),
    );
  }

  List<ScheduleEventModel> _eventsForDay(DateTime day) {
    return _selectedRecord.scheduleEvents
        .where((event) => _isSameDay(event.start, day))
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));
  }

  List<SectionAlert> _buildVisibleAlerts(SectionManagementRecord record) {
    return [
      ...record.alerts,
      if (record.capacityBand == SectionCapacityBand.full)
        const SectionAlert(
          title: 'Capacity full',
          message:
              'The section is fully occupied. New student additions should route to waitlist or transfer flow.',
          severity: 'critical',
        ),
      if (record.capacityBand == SectionCapacityBand.almostFull)
        const SectionAlert(
          title: 'Capacity threshold',
          message:
              'This section is approaching its ceiling. Review transfers before approving new enrollments.',
          severity: 'warning',
        ),
    ];
  }

  List<SectionLoadSnapshot> _sectionSnapshots() {
    return _records
        .map(
          (record) => SectionLoadSnapshot(
            id: record.id,
            label: record.code,
            department: record.department,
            yearLabel: record.yearLabel,
            usedSeats: record.studentsCount,
            capacity: record.capacity,
          ),
        )
        .toList();
  }

  void _selectRecord(SectionManagementRecord record) {
    setState(() {
      _selectedRecord = record;
      _activeTab = SectionDetailTab.overview;
      _selectedDay = record.scheduleEvents.isNotEmpty
          ? record.scheduleEvents.first.start
          : DateTime.now();
    });
  }

  void _toggleSectionActivation() {
    final updated = _selectedRecord.copyWith(
      status: _selectedRecord.isActive ? 'Inactive' : 'Active',
    );
    _replaceRecord(updated);
    _showSnack('${updated.code} is now ${updated.status.toLowerCase()}.');
  }

  void _moveStudents(Set<String> studentIds, String targetId) {
    if (studentIds.isEmpty) return;

    final source = _selectedRecord;
    final targetIndex = _records.indexWhere((record) => record.id == targetId);
    final sourceIndex = _records.indexWhere((record) => record.id == source.id);
    if (targetIndex == -1 || sourceIndex == -1) return;

    final movingStudents = source.students
        .where((student) => studentIds.contains(student.id))
        .toList();
    if (movingStudents.isEmpty) return;

    final updatedSource = source.copyWith(
      students: source.students
          .where((student) => !studentIds.contains(student.id))
          .toList(),
    );

    final target = _records[targetIndex];
    final updatedTarget = target.copyWith(
      students: [
        ...target.students,
        ...movingStudents.map(
          (student) => student.copyWith(currentSectionCode: target.code),
        ),
      ],
    );

    setState(() {
      _records[sourceIndex] = updatedSource;
      _records[targetIndex] = updatedTarget;
      _selectedRecord = updatedSource;
    });

    _showSnack(
      '${movingStudents.length} students moved from ${source.code} to ${target.code}.',
    );
  }

  void _replaceRecord(SectionManagementRecord updated) {
    final index = _records.indexWhere((record) => record.id == updated.id);
    if (index == -1) return;
    setState(() {
      _records[index] = updated;
      _selectedRecord = updated;
    });
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showAddSectionDialog(BuildContext context) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Add Section Form',
      barrierColor: Colors.black.withValues(alpha: 0.18),
      transitionDuration: AppMotion.slow,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: _AddSectionFormDialog(
            onCreated: (newRecord) {
              setState(() {
                _records.add(newRecord);
                _selectedRecord = newRecord;
              });
              _showSnack(
                context.l10n.byValue('New section created successfully.'),
              );
            },
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: AppMotion.entrance,
          reverseCurve: AppMotion.emphasized,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}

class _AddSectionFormDialog extends StatefulWidget {
  const _AddSectionFormDialog({required this.onCreated});

  final ValueChanged<SectionManagementRecord> onCreated;

  @override
  State<_AddSectionFormDialog> createState() => _AddSectionFormDialogState();
}

class _AddSectionFormDialogState extends State<_AddSectionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _capacityController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _department = 'Computer Science';
  int _yearValue = 2;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _capacityController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final newRecord = SectionManagementRecord(
      id: 'sec-${_codeController.text.trim().toLowerCase().replaceAll(' ', '-')}',
      name: _nameController.text.trim(),
      code: _codeController.text.trim(),
      department: _department,
      yearLabel: 'Year $_yearValue',
      yearValue: _yearValue,
      semesterLabel: 'Spring 2026',
      status: 'Active',
      capacity: int.parse(_capacityController.text.trim()),
      description: _descriptionController.text.trim().isEmpty
          ? 'A new section created dynamically.'
          : _descriptionController.text.trim(),
      locationLabel: _locationController.text.trim(),
      lastUpdatedLabel: 'Just created',
      students: const [],
      subjects: const [],
      staff: const [],
      scheduleEvents: const [],
      performanceTrend: const [],
      alerts: const [],
    );

    widget.onCreated(newRecord);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final resolvedTitle = context.l10n.byValue('New section');
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 680),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.dialogRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Material(
                color: Theme.of(context).cardColor.withValues(alpha: 0.94),
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
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
                                    resolvedTitle,
                                    style: Theme.of(context).textTheme.headlineSmall,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    context.l10n.byValue('Compare sibling cohorts, overloaded groups, and empty capacity before moving students.'),
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.close_rounded),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Wrap(
                              spacing: AppSpacing.md,
                              runSpacing: AppSpacing.md,
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: AppTextField(
                                    controller: _nameController,
                                    label: context.l10n.byValue('Cohort Name'),
                                    hint: context.l10n.byValue('Software Engineering Cohort C'),
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) {
                                        return context.l10n.byValue('Name is required');
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 260,
                                  child: AppTextField(
                                    controller: _codeController,
                                    label: context.l10n.byValue('Section Code'),
                                    hint: 'CS-Y2-C',
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) {
                                        return context.l10n.byValue('Code is required');
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 260,
                                  child: AppTextField(
                                    controller: _capacityController,
                                    label: context.l10n.byValue('Capacity'),
                                    hint: '60',
                                    keyboardType: TextInputType.number,
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) {
                                        return context.l10n.byValue('Capacity is required');
                                      }
                                      final parsed = int.tryParse(val);
                                      if (parsed == null || parsed <= 0) {
                                        return context.l10n.byValue('Enter a valid number');
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 260,
                                  child: AppDropdownField<String>(
                                    label: context.l10n.byValue('Department'),
                                    value: _department,
                                    onChanged: (val) => setState(() => _department = val ?? _department),
                                    items: [
                                      AppDropdownItem(
                                        value: 'Computer Science',
                                        label: context.l10n.byValue('Computer Science'),
                                      ),
                                      AppDropdownItem(
                                        value: 'Artificial Intelligence',
                                        label: context.l10n.byValue('Artificial Intelligence'),
                                      ),
                                      AppDropdownItem(
                                        value: 'Information Systems',
                                        label: context.l10n.byValue('Information Systems'),
                                      ),
                                      AppDropdownItem(
                                        value: 'Data Science',
                                        label: context.l10n.byValue('Data Science'),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 260,
                                  child: AppDropdownField<int>(
                                    label: context.l10n.byValue('Year'),
                                    value: _yearValue,
                                    onChanged: (val) => setState(() => _yearValue = val ?? _yearValue),
                                    items: [
                                      AppDropdownItem(
                                        value: 1,
                                        label: 'Year 1',
                                      ),
                                      AppDropdownItem(
                                        value: 2,
                                        label: 'Year 2',
                                      ),
                                      AppDropdownItem(
                                        value: 3,
                                        label: 'Year 3',
                                      ),
                                      AppDropdownItem(
                                        value: 4,
                                        label: 'Year 4',
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: AppTextField(
                                    controller: _locationController,
                                    label: context.l10n.byValue('Location'),
                                    hint: context.l10n.byValue('Innovation Building 4B'),
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) {
                                        return context.l10n.byValue('Location is required');
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: AppTextField(
                                    controller: _descriptionController,
                                    label: context.l10n.byValue('Description'),
                                    hint: 'A description for the section...',
                                    maxLines: 3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(context.l10n.byValue('Cancel')),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            PremiumButton(
                              label: 'Create Section',
                              icon: Icons.check_circle_outline_rounded,
                              onPressed: _submitForm,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
