import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/animations/app_motion.dart';
import '../../../core/colors/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/responsive/app_breakpoints.dart';
import '../../../core/spacing/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../shared/models/schedule_models.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../shared/widgets/status_badge.dart';
import 'charts/section_analytics_charts.dart';
import '../models/section_management_models.dart';
import 'widgets/section_management_primitives.dart';

class SectionsScreen extends StatefulWidget {
  const SectionsScreen({super.key});

  @override
  State<SectionsScreen> createState() => _SectionsScreenState();
}

class _SectionsScreenState extends State<SectionsScreen> {
  late final List<SectionManagementRecord> _records;
  late SectionManagementRecord _selectedRecord;
  late DateTime _selectedDay;

  SectionDetailTab _activeTab = SectionDetailTab.overview;
  SectionScheduleViewMode _scheduleViewMode = SectionScheduleViewMode.week;
  String _studentQuery = '';
  String _studentStatusFilter = 'All';
  String _studentYearFilter = 'All';
  String _studentDepartmentFilter = 'All';
  int _studentPage = 0;
  final Set<String> _selectedStudentIds = <String>{};

  @override
  void initState() {
    super.initState();
    _records = _buildMockSections();
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF6F8FC), Color(0xFFEFF4FB), Color(0xFFF8FAFD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          const Positioned(
            top: -120,
            right: -80,
            child: _BackdropOrb(size: 280, color: Color(0x332563EB)),
          ),
          const Positioned(
            top: 280,
            left: -100,
            child: _BackdropOrb(size: 240, color: Color(0x2216A34A)),
          ),
          const Positioned(
            bottom: -120,
            right: 160,
            child: _BackdropOrb(size: 260, color: Color(0x22F59E0B)),
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
                      final showSidebarPreview = constraints.maxWidth >= 1480;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeroHeader(context, constraints.maxWidth < 900),
                          const SizedBox(height: AppSpacing.lg),
                          _buildPortfolioStrip(context),
                          const SizedBox(height: AppSpacing.lg),
                          _buildTabBar(),
                          const SizedBox(height: AppSpacing.lg),
                          if (showSidebarPreview)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildMainWorkspace(context)),
                                const SizedBox(width: AppSpacing.xl),
                                SizedBox(
                                  width: 360,
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

  Widget _buildHeroHeader(BuildContext context, bool compact) {
    final record = _selectedRecord;
    final capacityColor = capacityBandColor(record.capacityBand);
    final alertLabel = switch (record.capacityBand) {
      SectionCapacityBand.available =>
        '${record.availableSeats} seats available',
      SectionCapacityBand.almostFull => 'Almost full, review incoming adds',
      SectionCapacityBand.full => 'Section full, waitlist active',
    };

    return SectionGlassPanel(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroIdentity(context),
                const SizedBox(height: AppSpacing.lg),
                _buildHeroCapacityCard(context, alertLabel, capacityColor),
                const SizedBox(height: AppSpacing.lg),
                _buildHeroActions(),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroIdentity(context),
                      const SizedBox(height: AppSpacing.lg),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          _InfoPill(
                            icon: Icons.apartment_rounded,
                            label: record.department,
                          ),
                          _InfoPill(
                            icon: Icons.school_rounded,
                            label: record.yearLabel,
                          ),
                          _InfoPill(
                            icon: Icons.auto_stories_rounded,
                            label: record.semesterLabel,
                          ),
                          _InfoPill(
                            icon: Icons.place_outlined,
                            label: record.locationLabel,
                          ),
                          _InfoPill(
                            icon: Icons.sync_rounded,
                            label: record.lastUpdatedLabel,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xl),
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildHeroActions(),
                      const SizedBox(height: AppSpacing.lg),
                      _buildHeroCapacityCard(
                        context,
                        alertLabel,
                        capacityColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeroIdentity(BuildContext context) {
    final record = _selectedRecord;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Section Management',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.primary,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(record.name, style: Theme.of(context).textTheme.displayMedium),
            _CodeBadge(code: record.code),
            StatusBadge(record.status),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          record.description,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondaryLight),
        ),
      ],
    );
  }

  Widget _buildHeroCapacityCard(
    BuildContext context,
    String alertLabel,
    Color accentColor,
  ) {
    final record = _selectedRecord;
    return AppCard(
      backgroundColor: Colors.white.withValues(alpha: 0.78),
      borderColor: accentColor.withValues(alpha: 0.20),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.people_alt_rounded, color: accentColor),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Capacity management',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alertLabel,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: accentColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionCapacityBar(
            value: record.capacityUsage,
            label:
                '${record.studentsCount} filled of ${record.capacity} total seats',
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _MiniCapacityStat(
                  label: 'Available',
                  value: math.max(record.availableSeats, 0).toString(),
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MiniCapacityStat(
                  label: 'Waitlist',
                  value: record.waitlistCount.toString(),
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MiniCapacityStat(
                  label: 'Capacity %',
                  value: '${record.capacityUsagePercent}%',
                  color: accentColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroActions() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      alignment: WrapAlignment.end,
      children: [
        PremiumButton(
          label: 'Edit',
          icon: Icons.edit_outlined,
          isSecondary: true,
          onPressed: () => _showSnack(
            'Edit panel is ready for form wiring to the real section editor.',
          ),
        ),
        PremiumButton(
          label: 'Delete',
          icon: Icons.delete_outline_rounded,
          isDestructive: true,
          onPressed: () => _showSnack(
            'Delete action is intentionally mocked to protect the sample data.',
          ),
        ),
        PremiumButton(
          label: _selectedRecord.isActive ? 'Deactivate' : 'Activate',
          icon: _selectedRecord.isActive
              ? Icons.pause_circle_outline_rounded
              : Icons.play_circle_outline_rounded,
          onPressed: _toggleSectionActivation,
        ),
      ],
    );
  }

  Widget _buildPortfolioStrip(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionPanelHeader(
          title: 'Section portfolio',
          subtitle:
              'Compare sibling cohorts, overloaded groups, and empty capacity before moving students.',
          trailing: Text(
            '${_records.length} active cohorts',
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 170,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _records.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              final record = _records[index];
              return SizedBox(
                width: 290,
                child: SectionPortfolioCard(
                  record: record,
                  selected: record.id == _selectedRecord.id,
                  onTap: () => _selectRecord(record),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      backgroundColor: Colors.white.withValues(alpha: 0.72),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (final tab in SectionDetailTab.values)
            SectionSegmentChip(
              label: _tabLabel(tab),
              selected: _activeTab == tab,
              onTap: () => setState(() => _activeTab = tab),
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
          SectionDetailTab.overview => _buildOverviewTab(context),
          SectionDetailTab.students => _buildStudentsTab(context),
          SectionDetailTab.schedule => _buildScheduleTab(context),
          SectionDetailTab.subjects => _buildSubjectsTab(context),
          SectionDetailTab.staff => _buildStaffTab(context),
        },
      ),
    );
  }

  Widget _buildDesktopSidebar(BuildContext context) {
    final visibleAlerts = _buildVisibleAlerts(_selectedRecord);
    final busiestSections = [..._records]
      ..sort((a, b) => b.capacityUsage.compareTo(a.capacityUsage));
    final previewEvents = _eventsForDay(_selectedDay).take(3).toList();

    return Column(
      children: [
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionPanelHeader(
                title: 'Capacity watch',
                subtitle:
                    'Real-time operational signals across this section and nearby cohorts.',
              ),
              const SizedBox(height: AppSpacing.md),
              SectionCapacityBar(
                value: _selectedRecord.capacityUsage,
                label:
                    '${_selectedRecord.studentsCount}/${_selectedRecord.capacity} occupied',
              ),
              const SizedBox(height: AppSpacing.md),
              for (final alert in visibleAlerts.take(3)) ...[
                SectionAlertBanner(alert: alert),
                const SizedBox(height: AppSpacing.sm),
              ],
              const SizedBox(height: AppSpacing.sm),
              for (final section in busiestSections.take(3)) ...[
                _SidebarLoadTile(record: section),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _DesktopMobilePreview(
          record: _selectedRecord,
          activeTab: _activeTab,
          events: previewEvents,
        ),
      ],
    );
  }

  Widget _buildOverviewTab(BuildContext context) {
    final record = _selectedRecord;
    final isDesktop = AppBreakpoints.isDesktop(context);
    final visibleAlerts = _buildVisibleAlerts(record);
    final sortedSnapshots = [..._sectionSnapshots()]
      ..sort((a, b) => b.usage.compareTo(a.usage));

    final metrics = [
      SectionMetricTile(
        label: 'Students',
        value: record.studentsCount.toString(),
        icon: Icons.groups_rounded,
        color: AppColors.primary,
        footer: '${record.activeStudentsCount} active roster',
      ),
      SectionMetricTile(
        label: 'Capacity',
        value: '${record.capacityUsagePercent}%',
        icon: Icons.speed_rounded,
        color: capacityBandColor(record.capacityBand),
        footer: '${record.capacity} total seats',
      ),
      SectionMetricTile(
        label: 'Assigned subjects',
        value: record.subjectsCount.toString(),
        icon: Icons.menu_book_rounded,
        color: AppColors.secondary,
        footer: '${record.subjects.length} teaching blocks',
      ),
      SectionMetricTile(
        label: 'Assigned staff',
        value: record.staffCount.toString(),
        icon: Icons.badge_rounded,
        color: AppColors.info,
        footer:
            '${record.doctorsCount} doctors, ${record.assistantsCount} assistants',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MetricGrid(metrics: metrics),
        if (visibleAlerts.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              for (final alert in visibleAlerts)
                SizedBox(
                  width: isDesktop ? 360 : double.infinity,
                  child: SectionAlertBanner(alert: alert),
                ),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        _ResponsiveTwoUp(
          leading: SectionDonutChartCard(
            title: 'Student distribution',
            subtitle:
                'Roster health by active, inactive, and at-risk student states.',
            points: record.studentDistribution,
            centerLabel: 'Students',
          ),
          trailing: SectionBarChartCard(
            title: 'Capacity usage',
            subtitle:
                'Live occupancy compared with available seats and waitlist pressure.',
            points: [
              SectionChartPoint(
                label: 'Filled',
                value: record.studentsCount.toDouble(),
              ),
              SectionChartPoint(
                label: 'Free',
                value: math.max(record.availableSeats, 0).toDouble(),
              ),
              SectionChartPoint(
                label: 'Waitlist',
                value: record.waitlistCount.toDouble(),
              ),
            ],
            color: capacityBandColor(record.capacityBand),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _ResponsiveTwoUp(
          leading: SectionLineChartCard(
            title: 'Section performance',
            subtitle:
                'Rolling composite score from GPA health, attendance, and delivery rhythm.',
            points: record.performanceTrend,
            color: AppColors.primary,
          ),
          trailing: SectionLoadComparisonCard(
            title: 'Overloaded and empty sections',
            subtitle:
                'Compare nearby cohorts before approving transfers or capacity changes.',
            snapshots: sortedSnapshots.take(4).toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _ResponsiveTwoUp(
          leading: AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionPanelHeader(
                  title: 'Subject delivery pulse',
                  subtitle:
                      'Completion and staffing coverage across the assigned subjects.',
                ),
                const SizedBox(height: AppSpacing.md),
                for (final subject in record.subjects) ...[
                  _SubjectPulseRow(subject: subject),
                  if (subject != record.subjects.last)
                    const SizedBox(height: AppSpacing.md),
                ],
              ],
            ),
          ),
          trailing: AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionPanelHeader(
                  title: 'Staff coverage',
                  subtitle:
                      'Teaching load and readiness across doctors and assistants.',
                ),
                const SizedBox(height: AppSpacing.md),
                for (
                  var index = 0;
                  index < record.staff.take(5).length;
                  index++
                ) ...[
                  _StaffPulseRow(member: record.staff[index]),
                  if (index != math.min(record.staff.length, 5) - 1)
                    const SizedBox(height: AppSpacing.md),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentsTab(BuildContext context) {
    final record = _selectedRecord;
    final deviceType = AppBreakpoints.resolve(context);
    final filteredStudents = _filteredStudents();
    final pageSize = deviceType == DeviceScreenType.mobile ? 4 : 6;
    final totalPages = math.max(1, (filteredStudents.length / pageSize).ceil());
    final currentPage = _studentPage.clamp(0, totalPages - 1);
    final visibleStudents = filteredStudents
        .skip(currentPage * pageSize)
        .take(pageSize)
        .toList();
    final transferTargets = _records
        .where((record) => record.id != _selectedRecord.id)
        .take(3)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionPanelHeader(
                title: 'Students',
                subtitle:
                    'Search, filter, bulk manage, and drag students across sections without losing visibility.',
                trailing: PremiumButton(
                  label: 'Add student',
                  icon: Icons.person_add_alt_1_rounded,
                  onPressed: () => _showSnack(
                    'Add student action is prepared for roster import or live search integration.',
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildStudentFilters(context),
              const SizedBox(height: AppSpacing.md),
              _buildBulkActionsBar(filteredStudents.length),
              const SizedBox(height: AppSpacing.lg),
              _buildDragDropBoard(visibleStudents, transferTargets),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (deviceType == DeviceScreenType.mobile)
          _buildStudentCards(visibleStudents)
        else
          _buildStudentsTable(visibleStudents),
        const SizedBox(height: AppSpacing.md),
        _PaginationBar(
          currentPage: currentPage,
          totalPages: totalPages,
          onPrevious: currentPage == 0
              ? null
              : () => setState(() => _studentPage = currentPage - 1),
          onNext: currentPage == totalPages - 1
              ? null
              : () => setState(() => _studentPage = currentPage + 1),
          label:
              'Showing ${visibleStudents.length} of ${filteredStudents.length} students in ${record.code}',
        ),
      ],
    );
  }

  Widget _buildStudentFilters(BuildContext context) {
    final yearOptions = [
      'All',
      ..._selectedRecord.students.map((student) => student.yearLabel).toSet(),
    ];
    final departmentOptions = [
      'All',
      ..._selectedRecord.students.map((student) => student.department).toSet(),
    ];

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        SizedBox(
          width: 280,
          child: TextField(
            onChanged: (value) => setState(() {
              _studentQuery = value;
              _studentPage = 0;
            }),
            decoration: const InputDecoration(
              hintText: 'Search by name, email, or student ID',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
        ),
        SizedBox(
          width: 170,
          child: _FilterDropdown(
            label: 'Status',
            value: _studentStatusFilter,
            items: const ['All', 'Active', 'Inactive'],
            onChanged: (value) => setState(() {
              _studentStatusFilter = value;
              _studentPage = 0;
            }),
          ),
        ),
        SizedBox(
          width: 170,
          child: _FilterDropdown(
            label: 'Year',
            value: _studentYearFilter,
            items: yearOptions,
            onChanged: (value) => setState(() {
              _studentYearFilter = value;
              _studentPage = 0;
            }),
          ),
        ),
        SizedBox(
          width: 190,
          child: _FilterDropdown(
            label: 'Department',
            value: _studentDepartmentFilter,
            items: departmentOptions,
            onChanged: (value) => setState(() {
              _studentDepartmentFilter = value;
              _studentPage = 0;
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildBulkActionsBar(int filteredCount) {
    final selectedCount = _selectedStudentIds.length;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.md,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            '$selectedCount selected  •  $filteredCount matching current filters',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          PremiumButton(
            label: 'Remove students',
            icon: Icons.person_remove_alt_1_rounded,
            isSecondary: true,
            onPressed: selectedCount == 0 ? null : _removeSelectedStudents,
          ),
          PremiumButton(
            label: 'Move students',
            icon: Icons.swap_horiz_rounded,
            onPressed: selectedCount == 0 ? null : _showBulkMoveSheet,
          ),
        ],
      ),
    );
  }

  Widget _buildDragDropBoard(
    List<SectionStudentRecord> visibleStudents,
    List<SectionManagementRecord> transferTargets,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Drag and drop assignment',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Drag roster cards into another cohort to simulate fast transfer decisions.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final student in visibleStudents.take(4))
              LongPressDraggable<SectionStudentRecord>(
                data: student,
                feedback: Material(
                  color: Colors.transparent,
                  child: _StudentDragChip(student: student, elevated: true),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.35,
                  child: _StudentDragChip(student: student),
                ),
                child: _StudentDragChip(student: student),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            for (final target in transferTargets)
              SizedBox(
                width: 260,
                child: DragTarget<SectionStudentRecord>(
                  onAcceptWithDetails: (details) =>
                      _moveStudents({details.data.id}, target.id),
                  builder: (context, candidates, rejected) {
                    final isHovering = candidates.isNotEmpty;
                    return AnimatedContainer(
                      duration: AppMotion.fast,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: isHovering
                            ? AppColors.secondary.withValues(alpha: 0.08)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(
                          AppConstants.mediumRadius,
                        ),
                        border: Border.all(
                          color: isHovering
                              ? AppColors.secondary
                              : Theme.of(context).dividerColor,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  target.code,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ),
                              StatusBadge(target.status),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            '${target.department} • ${target.yearLabel}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          SectionCapacityBar(
                            value: target.capacityUsage,
                            label:
                                '${target.studentsCount}/${target.capacity} seats',
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildStudentsTable(List<SectionStudentRecord> students) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          const _TableHeaderRow(
            columns: [
              _TableColumn(label: 'Student', flex: 3),
              _TableColumn(label: 'Status', flex: 2),
              _TableColumn(label: 'Year', flex: 1),
              _TableColumn(label: 'Department', flex: 2),
              _TableColumn(label: 'GPA', flex: 1),
              _TableColumn(label: 'Attendance', flex: 2),
              _TableColumn(label: 'Selection', flex: 1),
            ],
          ),
          for (final student in students)
            _StudentTableRow(
              student: student,
              selected: _selectedStudentIds.contains(student.id),
              onChanged: (checked) =>
                  _toggleStudentSelection(student.id, checked ?? false),
            ),
        ],
      ),
    );
  }

  Widget _buildStudentCards(List<SectionStudentRecord> students) {
    return Column(
      children: [
        for (final student in students) ...[
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SectionAvatar(
                      label: student.initials,
                      backgroundColor: student.isAtRisk
                          ? AppColors.warning
                          : AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            student.email,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Checkbox(
                      value: _selectedStudentIds.contains(student.id),
                      onChanged: (checked) =>
                          _toggleStudentSelection(student.id, checked ?? false),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    StatusBadge(student.status),
                    _InfoPill(
                      icon: Icons.school_outlined,
                      label: student.yearLabel,
                    ),
                    _InfoPill(
                      icon: Icons.apartment_rounded,
                      label: student.department,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _MetricLine(
                  label: 'GPA',
                  value: student.gpa.toStringAsFixed(2),
                ),
                const SizedBox(height: AppSpacing.xs),
                _MetricLine(
                  label: 'Attendance',
                  value: formatPercentValue(student.attendanceRate),
                ),
                const SizedBox(height: AppSpacing.xs),
                _MetricLine(
                  label: 'Last activity',
                  value: student.lastActivityLabel,
                ),
              ],
            ),
          ),
          if (student != students.last) const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }

  Widget _buildScheduleTab(BuildContext context) {
    final deviceType = AppBreakpoints.resolve(context);
    final visibleDays = _visibleScheduleDays();
    final dayEvents = _eventsForDay(_selectedDay);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionPanelHeader(
                title: 'Schedule',
                subtitle:
                    'Day and week views with responsive event blocks, today highlighting, and semantic event colors.',
              ),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SectionSegmentChip(
                    label: 'Day view',
                    selected: _scheduleViewMode == SectionScheduleViewMode.day,
                    onTap: () => setState(
                      () => _scheduleViewMode = SectionScheduleViewMode.day,
                    ),
                  ),
                  SectionSegmentChip(
                    label: 'Week view',
                    selected: _scheduleViewMode == SectionScheduleViewMode.week,
                    onTap: () => setState(
                      () => _scheduleViewMode = SectionScheduleViewMode.week,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(
                      () => _selectedDay = _selectedDay.subtract(
                        Duration(
                          days: _scheduleViewMode == SectionScheduleViewMode.day
                              ? 1
                              : 7,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.chevron_left_rounded),
                  ),
                  Text(
                    _scheduleViewMode == SectionScheduleViewMode.day
                        ? DateFormat('EEEE, MMM d').format(_selectedDay)
                        : '${DateFormat('MMM d').format(visibleDays.first)} - ${DateFormat('MMM d').format(visibleDays.last)}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  IconButton(
                    onPressed: () => setState(
                      () => _selectedDay = _selectedDay.add(
                        Duration(
                          days: _scheduleViewMode == SectionScheduleViewMode.day
                              ? 1
                              : 7,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                  PremiumButton(
                    label: 'Today',
                    icon: Icons.today_rounded,
                    isSecondary: true,
                    onPressed: () =>
                        setState(() => _selectedDay = DateTime.now()),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: const [
                  _LegendPill(label: 'Lecture', color: AppColors.primary),
                  _LegendPill(label: 'Section', color: AppColors.secondary),
                  _LegendPill(label: 'Exam', color: AppColors.danger),
                  _LegendPill(label: 'Quiz', color: AppColors.warning),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (deviceType == DeviceScreenType.mobile)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 74,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: visibleDays.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final day = visibleDays[index];
                    final selected = _isSameDay(day, _selectedDay);
                    return _DaySelectorChip(
                      day: day,
                      selected: selected,
                      onTap: () => setState(() => _selectedDay = day),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _MobileScheduleAgenda(events: dayEvents),
            ],
          )
        else
          _ScheduleBoard(
            days: visibleDays,
            selectedDay: _selectedDay,
            eventsByDay: {
              for (final day in visibleDays) day: _eventsForDay(day),
            },
          ),
      ],
    );
  }

  Widget _buildSubjectsTab(BuildContext context) {
    final subjects = _selectedRecord.subjects;
    final isMobile = AppBreakpoints.isMobile(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: SectionPanelHeader(
            title: 'Assigned subjects',
            subtitle:
                'Subject ownership, lecture counts, and instructor alignment for this section.',
            trailing: PremiumButton(
              label: 'Assign subject',
              icon: Icons.playlist_add_rounded,
              onPressed: () => _showSnack(
                'Assign subject flow is ready for API-backed search and attach behavior.',
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (isMobile)
          Column(
            children: [
              for (final subject in subjects) ...[
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${subject.code} • ${subject.title}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          StatusBadge(subject.status),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _MetricLine(
                        label: 'Instructor',
                        value: subject.instructorName,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      _MetricLine(
                        label: 'Lectures',
                        value: subject.lecturesCount.toString(),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      _MetricLine(
                        label: 'Delivery',
                        value: subject.deliveryLabel,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SectionCapacityBar(
                        value: subject.completionRate,
                        label:
                            '${(subject.completionRate * 100).round()}% delivery completion',
                      ),
                    ],
                  ),
                ),
                if (subject != subjects.last)
                  const SizedBox(height: AppSpacing.md),
              ],
            ],
          )
        else
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                const _TableHeaderRow(
                  columns: [
                    _TableColumn(label: 'Subject', flex: 3),
                    _TableColumn(label: 'Lectures', flex: 1),
                    _TableColumn(label: 'Instructor', flex: 2),
                    _TableColumn(label: 'Delivery', flex: 2),
                    _TableColumn(label: 'Status', flex: 1),
                    _TableColumn(label: 'Progress', flex: 2),
                  ],
                ),
                for (final subject in subjects)
                  _SubjectTableRow(subject: subject),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStaffTab(BuildContext context) {
    final staff = _selectedRecord.staff;
    final isDesktop = AppBreakpoints.isDesktop(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: SectionPanelHeader(
            title: 'Assigned staff',
            subtitle:
                'Manage doctors and assistants with role visibility, load balancing, and assignment controls.',
            trailing: PremiumButton(
              label: 'Assign staff',
              icon: Icons.person_add_alt_rounded,
              onPressed: () => _showSnack(
                'Assign staff flow is staged for directory search integration.',
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: staff.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isDesktop ? 2 : 1,
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: isDesktop ? 2.1 : 1.45,
          ),
          itemBuilder: (context, index) {
            final member = staff[index];
            return AppCard(
              interactive: true,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SectionAvatar(
                        label: member.initials,
                        backgroundColor: member.role == 'Doctor'
                            ? AppColors.primary
                            : AppColors.info,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              member.focusArea,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      StatusBadge(member.role),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(child: StatusBadge(member.status)),
                      Text(
                        member.officeHoursLabel,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SectionCapacityBar(
                    value: member.loadRate,
                    label: 'Teaching load ${(member.loadRate * 100).round()}%',
                  ),
                  const Spacer(),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      PremiumButton(
                        label: 'Assign',
                        icon: Icons.add_link_rounded,
                        isSecondary: true,
                        onPressed: () => _showSnack(
                          '${member.name} assignment control is in preview mode.',
                        ),
                      ),
                      PremiumButton(
                        label: 'Unassign',
                        icon: Icons.link_off_rounded,
                        isSecondary: true,
                        onPressed: () => _showSnack(
                          '${member.name} unassign confirmation is ready for backend wiring.',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  List<SectionStudentRecord> _filteredStudents() {
    final query = _studentQuery.trim().toLowerCase();
    return _selectedRecord.students.where((student) {
      final matchesQuery =
          query.isEmpty ||
          student.name.toLowerCase().contains(query) ||
          student.email.toLowerCase().contains(query) ||
          student.id.toLowerCase().contains(query);
      final matchesStatus =
          _studentStatusFilter == 'All' ||
          student.status == _studentStatusFilter;
      final matchesYear =
          _studentYearFilter == 'All' ||
          student.yearLabel == _studentYearFilter;
      final matchesDepartment =
          _studentDepartmentFilter == 'All' ||
          student.department == _studentDepartmentFilter;
      return matchesQuery && matchesStatus && matchesYear && matchesDepartment;
    }).toList();
  }

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
      _selectedStudentIds.clear();
      _studentPage = 0;
      _studentQuery = '';
      _studentStatusFilter = 'All';
      _studentYearFilter = 'All';
      _studentDepartmentFilter = 'All';
      _selectedDay = record.scheduleEvents.isNotEmpty
          ? record.scheduleEvents.first.start
          : DateTime.now();
    });
  }

  void _toggleStudentSelection(String studentId, bool selected) {
    setState(() {
      if (selected) {
        _selectedStudentIds.add(studentId);
      } else {
        _selectedStudentIds.remove(studentId);
      }
    });
  }

  void _toggleSectionActivation() {
    final updated = _selectedRecord.copyWith(
      status: _selectedRecord.isActive ? 'Inactive' : 'Active',
    );
    _replaceRecord(updated);
    _showSnack('${updated.code} is now ${updated.status.toLowerCase()}.');
  }

  void _removeSelectedStudents() {
    final updated = _selectedRecord.copyWith(
      students: _selectedRecord.students
          .where((student) => !_selectedStudentIds.contains(student.id))
          .toList(),
    );
    final removedCount = _selectedStudentIds.length;
    _replaceRecord(updated);
    setState(() => _selectedStudentIds.clear());
    _showSnack('$removedCount students were removed from ${updated.code}.');
  }

  Future<void> _showBulkMoveSheet() async {
    final target = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      showDragHandle: true,
      builder: (context) {
        final targets = _records.where(
          (record) => record.id != _selectedRecord.id,
        );
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Move selected students',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Choose the target section for the current selection.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              for (final target in targets)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(target.code),
                  subtitle: Text('${target.department} • ${target.yearLabel}'),
                  trailing: Text(
                    '${target.studentsCount}/${target.capacity}',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  onTap: () => Navigator.of(context).pop(target.id),
                ),
            ],
          ),
        );
      },
    );

    if (!mounted || target == null) return;
    _moveStudents(_selectedStudentIds, target);
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
      _selectedStudentIds.removeAll(studentIds);
      _studentPage = 0;
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

  String _tabLabel(SectionDetailTab tab) => switch (tab) {
    SectionDetailTab.overview => 'Overview',
    SectionDetailTab.students => 'Students',
    SectionDetailTab.schedule => 'Schedule',
    SectionDetailTab.subjects => 'Subjects',
    SectionDetailTab.staff => 'Staff',
  };
}

class _BackdropOrb extends StatelessWidget {
  const _BackdropOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}

class _CodeBadge extends StatelessWidget {
  const _CodeBadge({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppConstants.pillRadius),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.16)),
      ),
      child: Text(
        code,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: AppColors.primary),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppConstants.pillRadius),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondaryLight),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _MiniCapacityStat extends StatelessWidget {
  const _MiniCapacityStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _SidebarLoadTile extends StatelessWidget {
  const _SidebarLoadTile({required this.record});

  final SectionManagementRecord record;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  record.code,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              StatusBadge(record.status),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SectionCapacityBar(
            value: record.capacityUsage,
            label: '${record.studentsCount}/${record.capacity} seats',
          ),
        ],
      ),
    );
  }
}

class _DesktopMobilePreview extends StatelessWidget {
  const _DesktopMobilePreview({
    required this.record,
    required this.activeTab,
    required this.events,
  });

  final SectionManagementRecord record;
  final SectionDetailTab activeTab;
  final List<ScheduleEventModel> events;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionPanelHeader(
            title: 'Mobile preview',
            subtitle:
                'A compact iOS-style adaptation for on-the-go section management.',
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Container(
              width: 290,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF101827),
                borderRadius: BorderRadius.circular(38),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight.withValues(alpha: 0.22),
                    blurRadius: 30,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  color: const Color(0xFFF7F9FD),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          height: 5,
                          width: 68,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        record.code,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        record.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      StatusBadge(record.status),
                      const SizedBox(height: AppSpacing.md),
                      AppCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        backgroundColor: Colors.white.withValues(alpha: 0.92),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Capacity',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            SectionCapacityBar(
                              value: record.capacityUsage,
                              label:
                                  '${record.studentsCount}/${record.capacity} seats',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        _mobilePreviewTitle(activeTab),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      if (activeTab == SectionDetailTab.schedule)
                        for (final event in events)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: _MobileEventCard(event: event),
                          )
                      else if (activeTab == SectionDetailTab.students)
                        for (final student in record.students.take(3))
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: _CompactStudentCell(student: student),
                          )
                      else if (activeTab == SectionDetailTab.subjects)
                        for (final subject in record.subjects.take(3))
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: _CompactSubjectCell(subject: subject),
                          )
                      else if (activeTab == SectionDetailTab.staff)
                        for (final staff in record.staff.take(3))
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: _CompactStaffCell(member: staff),
                          )
                      else
                        Column(
                          children: [
                            _CompactOverviewStat(
                              label: 'Students',
                              value: record.studentsCount.toString(),
                              color: AppColors.primary,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _CompactOverviewStat(
                              label: 'Subjects',
                              value: record.subjectsCount.toString(),
                              color: AppColors.secondary,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _CompactOverviewStat(
                              label: 'Staff',
                              value: record.staffCount.toString(),
                              color: AppColors.info,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _mobilePreviewTitle(SectionDetailTab tab) => switch (tab) {
    SectionDetailTab.overview => 'Quick summary',
    SectionDetailTab.students => 'Roster cards',
    SectionDetailTab.schedule => 'Agenda',
    SectionDetailTab.subjects => 'Subject list',
    SectionDetailTab.staff => 'Staff cards',
  };
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.metrics});

  final List<Widget> metrics;

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppBreakpoints.isDesktop(context);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: metrics.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 4 : 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: isDesktop ? 1.45 : 1.10,
      ),
      itemBuilder: (context, index) => metrics[index],
    );
  }
}

class _ResponsiveTwoUp extends StatelessWidget {
  const _ResponsiveTwoUp({required this.leading, required this.trailing});

  final Widget leading;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppBreakpoints.isDesktop(context);
    if (!isDesktop) {
      return Column(
        children: [
          leading,
          const SizedBox(height: AppSpacing.lg),
          trailing,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: leading),
        const SizedBox(width: AppSpacing.lg),
        Expanded(child: trailing),
      ],
    );
  }
}

class _SubjectPulseRow extends StatelessWidget {
  const _SubjectPulseRow({required this.subject});

  final SectionSubjectRecord subject;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${subject.code} • ${subject.title}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            StatusBadge(subject.status),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${subject.instructorName} • ${subject.lecturesCount} lectures',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        SectionCapacityBar(
          value: subject.completionRate,
          label: '${(subject.completionRate * 100).round()}% complete',
        ),
      ],
    );
  }
}

class _StaffPulseRow extends StatelessWidget {
  const _StaffPulseRow({required this.member});

  final SectionStaffRecord member;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SectionAvatar(
          label: member.initials,
          backgroundColor: member.role == 'Doctor'
              ? AppColors.primary
              : AppColors.info,
          radius: 20,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(member.name, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(
                '${member.role} • ${member.focusArea}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        SizedBox(
          width: 110,
          child: SectionCapacityBar(
            value: member.loadRate,
            label: '${(member.loadRate * 100).round()}%',
          ),
        ),
      ],
    );
  }
}

class _StudentDragChip extends StatelessWidget {
  const _StudentDragChip({required this.student, this.elevated = false});

  final SectionStudentRecord student;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.pillRadius),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: AppColors.shadowLight.withValues(alpha: 0.16),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.drag_indicator_rounded,
            size: 18,
            color: AppColors.textSecondaryLight,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(student.name, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final item in items)
          DropdownMenuItem(value: item, child: Text(item)),
      ],
      onChanged: (selected) {
        if (selected != null) onChanged(selected);
      },
    );
  }
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.label,
    required this.onPrevious,
    required this.onNext,
  });

  final int currentPage;
  final int totalPages;
  final String label;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          IconButton(
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Text(
            '${currentPage + 1} / $totalPages',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}

class _LegendPill extends StatelessWidget {
  const _LegendPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppConstants.pillRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 10,
            width: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _DaySelectorChip extends StatelessWidget {
  const _DaySelectorChip({
    required this.day,
    required this.selected,
    required this.onTap,
  });

  final DateTime day;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isToday = _isSameDay(day, DateTime.now());
    return AnimatedContainer(
      duration: AppMotion.fast,
      decoration: BoxDecoration(
        color: selected
            ? AppColors.primary
            : Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        border: Border.all(
          color: selected
              ? AppColors.primary
              : isToday
              ? AppColors.info
              : Theme.of(context).dividerColor,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat('EEE').format(day),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: selected ? Colors.white : null,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('d').format(day),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: selected ? Colors.white : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileScheduleAgenda extends StatelessWidget {
  const _MobileScheduleAgenda({required this.events});

  final List<ScheduleEventModel> events;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return AppCard(
        child: Text(
          'No scheduled events for the selected day.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    return Column(
      children: [
        for (final event in events) ...[
          _MobileEventCard(event: event),
          if (event != events.last) const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _MobileEventCard extends StatelessWidget {
  const _MobileEventCard({required this.event});

  final ScheduleEventModel event;

  @override
  Widget build(BuildContext context) {
    final color = scheduleTypeColor(event.type);
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      backgroundColor: color.withValues(alpha: 0.06),
      borderColor: color.withValues(alpha: 0.16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  event.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              StatusBadge(event.type.toUpperCase()),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(event.course, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.md),
          _MetricLine(
            label: 'Time',
            value:
                '${DateFormat('hh:mm a').format(event.start)} - ${DateFormat('hh:mm a').format(event.end)}',
          ),
          const SizedBox(height: AppSpacing.xs),
          _MetricLine(label: 'Instructor', value: event.instructor),
          const SizedBox(height: AppSpacing.xs),
          _MetricLine(label: 'Location', value: event.location),
        ],
      ),
    );
  }
}

class _ScheduleBoard extends StatelessWidget {
  const _ScheduleBoard({
    required this.days,
    required this.selectedDay,
    required this.eventsByDay,
  });

  final List<DateTime> days;
  final DateTime selectedDay;
  final Map<DateTime, List<ScheduleEventModel>> eventsByDay;

  @override
  Widget build(BuildContext context) {
    const startHour = 8;
    const totalHours = 11;
    const timeColumnWidth = 72.0;
    const boardHeight = 620.0;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: timeColumnWidth),
              for (final day in days)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Column(
                      children: [
                        Text(
                          DateFormat('EEE').format(day),
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: _isSameDay(day, DateTime.now())
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(
                              AppConstants.pillRadius,
                            ),
                          ),
                          child: Text(
                            DateFormat('d MMM').format(day),
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: _isSameDay(day, DateTime.now())
                                      ? Colors.white
                                      : null,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(
            height: boardHeight,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final columnWidth =
                    (constraints.maxWidth - timeColumnWidth) / days.length;
                return Stack(
                  children: [
                    Positioned.fill(
                      child: Row(
                        children: [
                          const SizedBox(width: timeColumnWidth),
                          for (final day in days)
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _isSameDay(day, DateTime.now())
                                      ? AppColors.primary.withValues(
                                          alpha: 0.04,
                                        )
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(
                                    AppConstants.mediumRadius,
                                  ),
                                  border: Border.all(
                                    color: Theme.of(
                                      context,
                                    ).dividerColor.withValues(alpha: 0.42),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    for (var slot = 0; slot <= totalHours; slot++)
                      Positioned(
                        top: slot * (boardHeight / totalHours),
                        left: 0,
                        right: 0,
                        child: Row(
                          children: [
                            SizedBox(
                              width: timeColumnWidth,
                              child: Text(
                                DateFormat('hh a').format(
                                  DateTime(2026, 1, 1, startHour + slot),
                                ),
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Theme.of(
                                  context,
                                ).dividerColor.withValues(alpha: 0.55),
                              ),
                            ),
                          ],
                        ),
                      ),
                    for (var index = 0; index < days.length; index++)
                      for (final event in eventsByDay[days[index]] ?? const [])
                        Positioned(
                          left: timeColumnWidth + (columnWidth * index) + 8,
                          top: _eventTop(
                            event,
                            startHour,
                            totalHours,
                            boardHeight,
                          ),
                          width: columnWidth - 16,
                          height: _eventHeight(event, totalHours, boardHeight),
                          child: _ScheduleEventBlock(event: event),
                        ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static double _eventTop(
    ScheduleEventModel event,
    int startHour,
    int totalHours,
    double boardHeight,
  ) {
    final eventStartHour = event.start.hour + (event.start.minute / 60);
    final offset = (eventStartHour - startHour) / totalHours;
    return offset * boardHeight + 4;
  }

  static double _eventHeight(
    ScheduleEventModel event,
    int totalHours,
    double boardHeight,
  ) {
    final hours = event.end.difference(event.start).inMinutes / 60;
    return math.max((hours / totalHours) * boardHeight - 8, 58);
  }
}

class _ScheduleEventBlock extends StatelessWidget {
  const _ScheduleEventBlock({required this.event});

  final ScheduleEventModel event;

  @override
  Widget build(BuildContext context) {
    final color = scheduleTypeColor(event.type);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppConstants.smallRadius),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            event.course,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Spacer(),
          Text(
            '${DateFormat('hh:mm').format(event.start)} - ${DateFormat('hh:mm').format(event.end)}',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _TableColumn {
  const _TableColumn({required this.label, required this.flex});

  final String label;
  final int flex;
}

class _TableHeaderRow extends StatelessWidget {
  const _TableHeaderRow({required this.columns});

  final List<_TableColumn> columns;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppConstants.cardRadius),
        ),
      ),
      child: Row(
        children: [
          for (final column in columns)
            Expanded(
              flex: column.flex,
              child: Text(
                column.label,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
        ],
      ),
    );
  }
}

class _StudentTableRow extends StatelessWidget {
  const _StudentTableRow({
    required this.student,
    required this.selected,
    required this.onChanged,
  });

  final SectionStudentRecord student;
  final bool selected;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                SectionAvatar(
                  label: student.initials,
                  backgroundColor: student.isAtRisk
                      ? AppColors.warning
                      : AppColors.primary,
                  radius: 18,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        student.email,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(flex: 2, child: StatusBadge(student.status)),
          Expanded(flex: 1, child: Text(student.yearLabel)),
          Expanded(flex: 2, child: Text(student.department)),
          Expanded(flex: 1, child: Text(student.gpa.toStringAsFixed(2))),
          Expanded(
            flex: 2,
            child: Text(formatPercentValue(student.attendanceRate)),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Checkbox(value: selected, onChanged: onChanged),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectTableRow extends StatelessWidget {
  const _SubjectTableRow({required this.subject});

  final SectionSubjectRecord subject;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${subject.code} • ${subject.title}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  subject.deliveryLabel,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Expanded(flex: 1, child: Text(subject.lecturesCount.toString())),
          Expanded(flex: 2, child: Text(subject.instructorName)),
          Expanded(flex: 2, child: Text(subject.deliveryLabel)),
          Expanded(flex: 1, child: StatusBadge(subject.status)),
          Expanded(
            flex: 2,
            child: SectionCapacityBar(
              value: subject.completionRate,
              label: '${(subject.completionRate * 100).round()}%',
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricLine extends StatelessWidget {
  const _MetricLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        Text(value, style: Theme.of(context).textTheme.labelLarge),
      ],
    );
  }
}

class _CompactOverviewStat extends StatelessWidget {
  const _CompactOverviewStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
      ),
      child: Row(
        children: [
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.insights_rounded, color: color, size: 18),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Text(value, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}

class _CompactStudentCell extends StatelessWidget {
  const _CompactStudentCell({required this.student});

  final SectionStudentRecord student;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
      ),
      child: Row(
        children: [
          SectionAvatar(
            label: student.initials,
            backgroundColor: AppColors.primary,
            radius: 16,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  student.yearLabel,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          StatusBadge(student.status),
        ],
      ),
    );
  }
}

class _CompactSubjectCell extends StatelessWidget {
  const _CompactSubjectCell({required this.subject});

  final SectionSubjectRecord subject;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.code,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  subject.title,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            '${(subject.completionRate * 100).round()}%',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ],
      ),
    );
  }
}

class _CompactStaffCell extends StatelessWidget {
  const _CompactStaffCell({required this.member});

  final SectionStaffRecord member;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
      ),
      child: Row(
        children: [
          SectionAvatar(
            label: member.initials,
            backgroundColor: member.role == 'Doctor'
                ? AppColors.primary
                : AppColors.info,
            radius: 16,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(member.role, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Icon(
            member.status == 'Active'
                ? Icons.check_circle_rounded
                : Icons.pause_circle_rounded,
            size: 18,
            color: member.status == 'Active'
                ? AppColors.secondary
                : AppColors.warning,
          ),
        ],
      ),
    );
  }
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

DateTime _startOfWeek(DateTime date) {
  final normalized = _dateOnly(date);
  return normalized.subtract(Duration(days: normalized.weekday - 1));
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

List<SectionManagementRecord> _buildMockSections() {
  final weekStart = _startOfWeek(DateTime.now());
  final primarySubjects = [
    _subject(
      code: 'CS221',
      title: 'Object-Oriented Programming',
      lecturesCount: 14,
      instructorName: 'Dr. Hadeer Salah',
      deliveryLabel: 'Lecture + Lab',
      status: 'Active',
      completionRate: 0.82,
    ),
    _subject(
      code: 'CS223',
      title: 'Data Structures',
      lecturesCount: 12,
      instructorName: 'Dr. Salma Adel',
      deliveryLabel: 'Lecture + Section',
      status: 'Active',
      completionRate: 0.76,
    ),
    _subject(
      code: 'CS225',
      title: 'Discrete Mathematics',
      lecturesCount: 10,
      instructorName: 'Dr. Mostafa Nader',
      deliveryLabel: 'Lecture',
      status: 'Planned',
      completionRate: 0.65,
    ),
    _subject(
      code: 'CS227',
      title: 'Computer Architecture',
      lecturesCount: 11,
      instructorName: 'Dr. Reem Fawzy',
      deliveryLabel: 'Lecture + Lab',
      status: 'Active',
      completionRate: 0.71,
    ),
    _subject(
      code: 'CS229',
      title: 'Technical Writing',
      lecturesCount: 8,
      instructorName: 'Eng. Menna Wael',
      deliveryLabel: 'Workshop',
      status: 'Active',
      completionRate: 0.88,
    ),
  ];

  final primaryStaff = [
    _staff(
      id: 'stf-1',
      name: 'Dr. Hadeer Salah',
      role: 'Doctor',
      status: 'Active',
      focusArea: 'Programming foundations',
      officeHoursLabel: 'Sun & Tue • 11:00',
      loadRate: 0.74,
    ),
    _staff(
      id: 'stf-2',
      name: 'Dr. Salma Adel',
      role: 'Doctor',
      status: 'Active',
      focusArea: 'Algorithms and data structures',
      officeHoursLabel: 'Mon • 12:30',
      loadRate: 0.82,
    ),
    _staff(
      id: 'stf-3',
      name: 'Dr. Mostafa Nader',
      role: 'Doctor',
      status: 'Active',
      focusArea: 'Discrete systems',
      officeHoursLabel: 'Wed • 13:00',
      loadRate: 0.58,
    ),
    _staff(
      id: 'stf-4',
      name: 'Eng. Ahmed Samir',
      role: 'Assistant',
      status: 'Active',
      focusArea: 'Lab supervision',
      officeHoursLabel: 'Daily • 10:00',
      loadRate: 0.63,
    ),
    _staff(
      id: 'stf-5',
      name: 'Eng. Menna Wael',
      role: 'Assistant',
      status: 'Active',
      focusArea: 'Assessment operations',
      officeHoursLabel: 'Tue & Thu • 14:00',
      loadRate: 0.67,
    ),
    _staff(
      id: 'stf-6',
      name: 'Eng. Nourhan Essam',
      role: 'Assistant',
      status: 'Inactive',
      focusArea: 'Lab contingency coverage',
      officeHoursLabel: 'On-demand',
      loadRate: 0.28,
    ),
  ];

  final sectionAStudents = [
    _student(
      id: 'ST-2101',
      name: 'Mariam Tarek',
      email: 'mariam.tarek@tolab.edu',
      status: 'Active',
      department: 'Computer Science',
      yearLabel: 'Year 2',
      currentSectionCode: 'CS-Y2-A',
      gpa: 3.86,
      attendanceRate: 0.95,
      creditHours: 17,
      performanceLabel: 'Excellent',
      lastActivityLabel: '13 min ago',
    ),
    _student(
      id: 'ST-2102',
      name: 'Omar Adel',
      email: 'omar.adel@tolab.edu',
      status: 'Active',
      department: 'Computer Science',
      yearLabel: 'Year 2',
      currentSectionCode: 'CS-Y2-A',
      gpa: 3.72,
      attendanceRate: 0.91,
      creditHours: 17,
      performanceLabel: 'Strong',
      lastActivityLabel: '28 min ago',
    ),
    _student(
      id: 'ST-2103',
      name: 'Youssef Ali',
      email: 'youssef.ali@tolab.edu',
      status: 'Inactive',
      department: 'Computer Science',
      yearLabel: 'Year 2',
      currentSectionCode: 'CS-Y2-A',
      gpa: 2.41,
      attendanceRate: 0.68,
      creditHours: 14,
      performanceLabel: 'At risk',
      lastActivityLabel: 'Yesterday',
    ),
    _student(
      id: 'ST-2104',
      name: 'Sarah Emad',
      email: 'sarah.emad@tolab.edu',
      status: 'Active',
      department: 'Computer Science',
      yearLabel: 'Year 2',
      currentSectionCode: 'CS-Y2-A',
      gpa: 3.49,
      attendanceRate: 0.88,
      creditHours: 16,
      performanceLabel: 'Healthy',
      lastActivityLabel: '1 h ago',
    ),
    _student(
      id: 'ST-2105',
      name: 'Karim Nabil',
      email: 'karim.nabil@tolab.edu',
      status: 'Active',
      department: 'Artificial Intelligence',
      yearLabel: 'Year 2',
      currentSectionCode: 'CS-Y2-A',
      gpa: 3.11,
      attendanceRate: 0.84,
      creditHours: 15,
      performanceLabel: 'Stable',
      lastActivityLabel: '2 h ago',
    ),
    _student(
      id: 'ST-2106',
      name: 'Nada Gamal',
      email: 'nada.gamal@tolab.edu',
      status: 'Active',
      department: 'Computer Science',
      yearLabel: 'Year 2',
      currentSectionCode: 'CS-Y2-A',
      gpa: 3.68,
      attendanceRate: 0.93,
      creditHours: 17,
      performanceLabel: 'Strong',
      lastActivityLabel: '3 h ago',
    ),
    _student(
      id: 'ST-2107',
      name: 'Mohamed Ashraf',
      email: 'mohamed.ashraf@tolab.edu',
      status: 'Active',
      department: 'Data Science',
      yearLabel: 'Year 2',
      currentSectionCode: 'CS-Y2-A',
      gpa: 2.88,
      attendanceRate: 0.79,
      creditHours: 15,
      performanceLabel: 'Monitor',
      lastActivityLabel: 'Today',
    ),
    _student(
      id: 'ST-2108',
      name: 'Habiba Essam',
      email: 'habiba.essam@tolab.edu',
      status: 'Active',
      department: 'Computer Science',
      yearLabel: 'Year 2',
      currentSectionCode: 'CS-Y2-A',
      gpa: 3.95,
      attendanceRate: 0.97,
      creditHours: 18,
      performanceLabel: 'Excellent',
      lastActivityLabel: '35 min ago',
    ),
    _student(
      id: 'ST-2109',
      name: 'Ali Hossam',
      email: 'ali.hossam@tolab.edu',
      status: 'Active',
      department: 'Information Systems',
      yearLabel: 'Year 2',
      currentSectionCode: 'CS-Y2-A',
      gpa: 3.19,
      attendanceRate: 0.81,
      creditHours: 16,
      performanceLabel: 'Stable',
      lastActivityLabel: '4 h ago',
    ),
    _student(
      id: 'ST-2110',
      name: 'Menna Taha',
      email: 'menna.taha@tolab.edu',
      status: 'Active',
      department: 'Computer Science',
      yearLabel: 'Year 2',
      currentSectionCode: 'CS-Y2-A',
      gpa: 3.58,
      attendanceRate: 0.90,
      creditHours: 17,
      performanceLabel: 'Healthy',
      lastActivityLabel: '15 min ago',
    ),
  ];

  final sectionBStudents = [
    ...sectionAStudents
        .take(6)
        .map((student) => student.copyWith(currentSectionCode: 'CS-Y2-B')),
    _student(
      id: 'ST-2201',
      name: 'Lina Ahmed',
      email: 'lina.ahmed@tolab.edu',
      status: 'Active',
      department: 'Computer Science',
      yearLabel: 'Year 2',
      currentSectionCode: 'CS-Y2-B',
      gpa: 3.44,
      attendanceRate: 0.89,
      creditHours: 17,
      performanceLabel: 'Healthy',
      lastActivityLabel: '45 min ago',
    ),
    _student(
      id: 'ST-2202',
      name: 'Adam Saeed',
      email: 'adam.saeed@tolab.edu',
      status: 'Active',
      department: 'Artificial Intelligence',
      yearLabel: 'Year 2',
      currentSectionCode: 'CS-Y2-B',
      gpa: 3.07,
      attendanceRate: 0.82,
      creditHours: 15,
      performanceLabel: 'Stable',
      lastActivityLabel: 'Today',
    ),
  ];

  final aiStudents = [
    _student(
      id: 'ST-2301',
      name: 'Reem Fawzy',
      email: 'reem.fawzy@tolab.edu',
      status: 'Active',
      department: 'Artificial Intelligence',
      yearLabel: 'Year 2',
      currentSectionCode: 'AI-Y2-A',
      gpa: 3.76,
      attendanceRate: 0.93,
      creditHours: 18,
      performanceLabel: 'Strong',
      lastActivityLabel: '20 min ago',
    ),
    _student(
      id: 'ST-2302',
      name: 'Hassan Wael',
      email: 'hassan.wael@tolab.edu',
      status: 'Active',
      department: 'Artificial Intelligence',
      yearLabel: 'Year 2',
      currentSectionCode: 'AI-Y2-A',
      gpa: 3.34,
      attendanceRate: 0.85,
      creditHours: 16,
      performanceLabel: 'Healthy',
      lastActivityLabel: '1 h ago',
    ),
    _student(
      id: 'ST-2303',
      name: 'Farah Elsayed',
      email: 'farah.elsayed@tolab.edu',
      status: 'Inactive',
      department: 'Artificial Intelligence',
      yearLabel: 'Year 2',
      currentSectionCode: 'AI-Y2-A',
      gpa: 2.57,
      attendanceRate: 0.74,
      creditHours: 13,
      performanceLabel: 'At risk',
      lastActivityLabel: '2 days ago',
    ),
    _student(
      id: 'ST-2304',
      name: 'Bassel Sherif',
      email: 'bassel.sherif@tolab.edu',
      status: 'Active',
      department: 'Artificial Intelligence',
      yearLabel: 'Year 2',
      currentSectionCode: 'AI-Y2-A',
      gpa: 3.61,
      attendanceRate: 0.90,
      creditHours: 18,
      performanceLabel: 'Strong',
      lastActivityLabel: 'Today',
    ),
  ];

  return [
    SectionManagementRecord(
      id: 'sec-cs-y2-a',
      name: 'Software Engineering Cohort A',
      code: 'CS-Y2-A',
      department: 'Computer Science',
      yearLabel: 'Year 2',
      yearValue: 2,
      semesterLabel: 'Spring 2026',
      status: 'Active',
      capacity: 96,
      description:
          'Premium operations view for a high-demand second-year section with blended teaching, tight seat control, and strong academic monitoring.',
      locationLabel: 'Innovation Building 4B',
      lastUpdatedLabel: 'Updated 14 min ago',
      students: sectionAStudents,
      subjects: primarySubjects,
      staff: primaryStaff,
      scheduleEvents: _buildScheduleEvents(weekStart, 'CS-Y2-A'),
      performanceTrend: const [
        SectionChartPoint(label: 'W1', value: 72),
        SectionChartPoint(label: 'W2', value: 74),
        SectionChartPoint(label: 'W3', value: 79),
        SectionChartPoint(label: 'W4', value: 81),
        SectionChartPoint(label: 'W5', value: 84),
        SectionChartPoint(label: 'W6', value: 86),
      ],
      alerts: const [
        SectionAlert(
          title: 'Attendance dip',
          message:
              'Three students dropped below the attendance threshold during the last seven days.',
          severity: 'warning',
        ),
        SectionAlert(
          title: 'Quiz window opens tomorrow',
          message:
              'Coordinate section assistants before the Thursday quiz goes live.',
          severity: 'info',
        ),
      ],
    ),
    SectionManagementRecord(
      id: 'sec-cs-y2-b',
      name: 'Software Engineering Cohort B',
      code: 'CS-Y2-B',
      department: 'Computer Science',
      yearLabel: 'Year 2',
      yearValue: 2,
      semesterLabel: 'Spring 2026',
      status: 'Active',
      capacity: 84,
      description:
          'Balanced sister section with healthier seat availability and lighter transfer pressure.',
      locationLabel: 'Innovation Building 3A',
      lastUpdatedLabel: 'Updated 22 min ago',
      students: sectionBStudents,
      subjects: primarySubjects.take(4).toList(),
      staff: primaryStaff.take(5).toList(),
      scheduleEvents: _buildScheduleEvents(weekStart, 'CS-Y2-B'),
      performanceTrend: const [
        SectionChartPoint(label: 'W1', value: 68),
        SectionChartPoint(label: 'W2', value: 70),
        SectionChartPoint(label: 'W3', value: 73),
        SectionChartPoint(label: 'W4', value: 75),
        SectionChartPoint(label: 'W5', value: 77),
        SectionChartPoint(label: 'W6', value: 80),
      ],
      alerts: const [
        SectionAlert(
          title: 'Transfer capacity available',
          message:
              'This cohort can absorb up to 10 students without crossing the warning threshold.',
          severity: 'info',
        ),
      ],
    ),
    SectionManagementRecord(
      id: 'sec-ai-y2-a',
      name: 'Applied AI Cohort A',
      code: 'AI-Y2-A',
      department: 'Artificial Intelligence',
      yearLabel: 'Year 2',
      yearValue: 2,
      semesterLabel: 'Spring 2026',
      status: 'Inactive',
      capacity: 42,
      description:
          'Smaller AI cohort used here to surface empty-section analytics and staff utilization decisions.',
      locationLabel: 'Digital Lab 2C',
      lastUpdatedLabel: 'Updated 1 h ago',
      students: aiStudents,
      subjects: primarySubjects.take(3).toList(),
      staff: primaryStaff.take(4).toList(),
      scheduleEvents: _buildScheduleEvents(weekStart, 'AI-Y2-A'),
      performanceTrend: const [
        SectionChartPoint(label: 'W1', value: 64),
        SectionChartPoint(label: 'W2', value: 62),
        SectionChartPoint(label: 'W3', value: 66),
        SectionChartPoint(label: 'W4', value: 69),
        SectionChartPoint(label: 'W5', value: 71),
        SectionChartPoint(label: 'W6', value: 70),
      ],
      alerts: const [
        SectionAlert(
          title: 'Low utilization',
          message:
              'Section occupancy is far below target. Consider merging or rebalancing staffing.',
          severity: 'warning',
        ),
      ],
    ),
  ];
}

SectionStudentRecord _student({
  required String id,
  required String name,
  required String email,
  required String status,
  required String department,
  required String yearLabel,
  required String currentSectionCode,
  required double gpa,
  required double attendanceRate,
  required int creditHours,
  required String performanceLabel,
  required String lastActivityLabel,
}) {
  return SectionStudentRecord(
    id: id,
    name: name,
    email: email,
    status: status,
    department: department,
    yearLabel: yearLabel,
    currentSectionCode: currentSectionCode,
    gpa: gpa,
    attendanceRate: attendanceRate,
    creditHours: creditHours,
    performanceLabel: performanceLabel,
    lastActivityLabel: lastActivityLabel,
  );
}

SectionSubjectRecord _subject({
  required String code,
  required String title,
  required int lecturesCount,
  required String instructorName,
  required String deliveryLabel,
  required String status,
  required double completionRate,
}) {
  return SectionSubjectRecord(
    code: code,
    title: title,
    lecturesCount: lecturesCount,
    instructorName: instructorName,
    deliveryLabel: deliveryLabel,
    status: status,
    completionRate: completionRate,
  );
}

SectionStaffRecord _staff({
  required String id,
  required String name,
  required String role,
  required String status,
  required String focusArea,
  required String officeHoursLabel,
  required double loadRate,
}) {
  return SectionStaffRecord(
    id: id,
    name: name,
    role: role,
    status: status,
    focusArea: focusArea,
    officeHoursLabel: officeHoursLabel,
    loadRate: loadRate,
  );
}

List<ScheduleEventModel> _buildScheduleEvents(DateTime weekStart, String code) {
  return [
    ScheduleEventModel(
      id: '$code-ev-1',
      title: 'Lecture 08',
      course: 'Object-Oriented Programming',
      instructor: 'Dr. Hadeer Salah',
      location: 'Hall B12',
      type: 'lecture',
      status: 'planned',
      start: weekStart.add(const Duration(hours: 9)),
      end: weekStart.add(const Duration(hours: 11)),
      color: AppColors.primary,
    ),
    ScheduleEventModel(
      id: '$code-ev-2',
      title: 'Section Lab',
      course: 'Data Structures',
      instructor: 'Eng. Ahmed Samir',
      location: 'Lab C3',
      type: 'section',
      status: 'planned',
      start: weekStart.add(const Duration(hours: 12)),
      end: weekStart.add(const Duration(hours: 14)),
      color: AppColors.secondary,
    ),
    ScheduleEventModel(
      id: '$code-ev-3',
      title: 'Quiz 02',
      course: 'Discrete Mathematics',
      instructor: 'Dr. Mostafa Nader',
      location: 'Quiz Hall 1',
      type: 'quiz',
      status: 'planned',
      start: weekStart.add(const Duration(days: 2, hours: 10)),
      end: weekStart.add(const Duration(days: 2, hours: 11)),
      color: AppColors.warning,
    ),
    ScheduleEventModel(
      id: '$code-ev-4',
      title: 'Midterm Review',
      course: 'Computer Architecture',
      instructor: 'Dr. Reem Fawzy',
      location: 'Studio A',
      type: 'section',
      status: 'planned',
      start: weekStart.add(const Duration(days: 3, hours: 11)),
      end: weekStart.add(const Duration(days: 3, hours: 13)),
      color: AppColors.secondary,
    ),
    ScheduleEventModel(
      id: '$code-ev-5',
      title: 'Midterm Exam',
      course: 'Object-Oriented Programming',
      instructor: 'Dr. Hadeer Salah',
      location: 'Main Auditorium',
      type: 'exam',
      status: 'planned',
      start: weekStart.add(const Duration(days: 4, hours: 9)),
      end: weekStart.add(const Duration(days: 4, hours: 11)),
      color: AppColors.danger,
    ),
  ];
}
