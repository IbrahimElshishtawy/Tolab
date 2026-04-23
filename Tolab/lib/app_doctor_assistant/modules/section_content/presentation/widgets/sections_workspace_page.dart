import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../dashboard/presentation/theme/dashboard_theme_tokens.dart';
import '../../../dashboard/presentation/widgets/dashboard_section_primitives.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/state/async_state.dart';
import '../../../../models/doctor_assistant_models.dart';
import '../../../../presentation/widgets/doctor_assistant_widgets.dart';
import '../../../../presentation/widgets/quick_stats_section.dart';
import '../../state/section_content_state.dart';
import '../models/sections_workspace_models.dart';
import 'section_builder_form.dart';
import 'sections_overview_panel.dart';

class SectionsWorkspacePage extends StatefulWidget {
  const SectionsWorkspacePage({
    super.key,
    required this.sectionState,
    required this.workspaceData,
    required this.subjects,
    required this.onReload,
    required this.onSaveSection,
    required this.onPublishSection,
  });

  final SectionContentState sectionState;
  final SectionsWorkspaceData workspaceData;
  final List<TeachingSubject> subjects;
  final VoidCallback onReload;
  final ValueChanged<Map<String, dynamic>> onSaveSection;
  final ValueChanged<int> onPublishSection;

  @override
  State<SectionsWorkspacePage> createState() => _SectionsWorkspacePageState();
}

class _SectionsWorkspacePageState extends State<SectionsWorkspacePage> {
  final GlobalKey<SectionBuilderFormState> _formKey =
      GlobalKey<SectionBuilderFormState>();
  final GlobalKey _formAnchorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1180;

        final overviewPanel = SectionsOverviewPanel(
          data: widget.workspaceData,
          status: widget.sectionState.status,
          errorMessage: widget.sectionState.error,
          onRetry: widget.onReload,
          onCreateSection: _focusBuilder,
          onViewSection: _handleViewSection,
          onEditSection: _handleEditSection,
          onPublishSection: _handlePublishSection,
          onCopyLink: _handleCopyLink,
          onNotifyStudents: _handleNotifyStudents,
        );

        final builderPanel = KeyedSubtree(
          key: _formAnchorKey,
          child: SectionBuilderForm(
            key: _formKey,
            subjects: widget.subjects,
            onSaveSection: widget.onSaveSection,
          ),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _QuickActionsSection(actions: widget.workspaceData.quickActions),
            const SizedBox(height: AppSpacing.lg),
            QuickStatsSection(
              title: 'Section Quick Stats',
              subtitle:
                  'A fast read on this week\'s section volume, readiness, and attendance pressure.',
              metrics: widget.workspaceData.metrics,
            ),
            const SizedBox(height: AppSpacing.lg),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              child: isWide
                  ? Row(
                      key: const ValueKey('sections-wide'),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 6, child: overviewPanel),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(flex: 5, child: builderPanel),
                      ],
                    )
                  : Column(
                      key: const ValueKey('sections-stacked'),
                      children: [
                        overviewPanel,
                        const SizedBox(height: AppSpacing.lg),
                        builderPanel,
                      ],
                    ),
            ),
            if (widget.sectionState.status == ViewStatus.loading &&
                widget.workspaceData.sections.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              const LinearProgressIndicator(minHeight: 3),
            ],
          ],
        );
      },
    );
  }

  void _focusBuilder() {
    final contextForForm = _formAnchorKey.currentContext;
    if (contextForForm == null) {
      return;
    }
    Scrollable.ensureVisible(
      contextForForm,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );
  }

  void _handleEditSection(SectionWorkspaceItem section) {
    _focusBuilder();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _formKey.currentState?.prefillFromSection(section);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Loaded ${section.title} into the builder.')),
      );
    });
  }

  void _handlePublishSection(SectionWorkspaceItem section) {
    widget.onPublishSection(section.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${section.title} is now aligned for publishing.'),
      ),
    );
  }

  Future<void> _handleCopyLink(SectionWorkspaceItem section) async {
    final link = section.meetingLink ?? section.locationLabel;
    await Clipboard.setData(ClipboardData(text: link));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Access details copied for ${section.title}.')),
    );
  }

  void _handleNotifyStudents(SectionWorkspaceItem section) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Reminder queued for ${section.expectedStudents} students in ${section.title}.',
        ),
      ),
    );
  }

  Future<void> _handleViewSection(SectionWorkspaceItem section) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final tokens = DashboardThemeTokens.of(dialogContext);
        return AlertDialog(
          backgroundColor: tokens.surface,
          title: Text(section.title),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.subjectLabel,
                  style: Theme.of(dialogContext).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                _DetailRow(label: 'Date', value: section.dateLabel),
                _DetailRow(label: 'Time', value: section.timeLabel),
                _DetailRow(label: 'Mode', value: section.deliveryType),
                _DetailRow(label: 'Owner', value: section.assistantName),
                _DetailRow(label: 'Location', value: section.locationLabel),
                _DetailRow(
                  label: 'Expected attendance',
                  value: '${section.expectedStudents} students',
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  section.description,
                  style: Theme.of(dialogContext).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
            FilledButton.tonalIcon(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.go('${AppRoutes.subjects}/${section.subjectId}');
              },
              icon: const Icon(Icons.menu_book_rounded, size: 18),
              label: const Text('Open Subject'),
            ),
          ],
        );
      },
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection({required this.actions});

  final List<WorkspaceQuickAction> actions;

  @override
  Widget build(BuildContext context) {
    return DashboardSectionCard(
      title: 'Section Actions',
      subtitle:
          'Jump into the adjacent workflows that usually follow section creation.',
      child: DoctorAssistantQuickActionGrid(actions: actions),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
