import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/colors/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/spacing/app_spacing.dart';
import '../../../shared/enums/load_status.dart';
import '../state/dashboard_state.dart';

class DashboardFilterBar extends StatelessWidget {
  const DashboardFilterBar({
    super.key,
    required this.bundle,
    required this.filters,
    required this.searchQuery,
    required this.searchScope,
    required this.searchStatus,
    required this.lastRealtimeSignalAt,
    required this.onSearchChanged,
    required this.onScopeChanged,
    required this.onTimeRangeChanged,
  });

  final DashboardBundle bundle;
  final DashboardFilters filters;
  final String searchQuery;
  final DashboardSearchScope searchScope;
  final LoadStatus searchStatus;
  final DateTime? lastRealtimeSignalAt;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<DashboardSearchScope> onScopeChanged;
  final ValueChanged<DashboardTimeRange> onTimeRangeChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.strokeDark : AppColors.strokeLight;
    final background = isDark
        ? AppColors.surfaceDark.withValues(alpha: 0.70)
        : Colors.white.withValues(alpha: 0.72);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.dialogRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.dialogRadius),
            border: Border.all(color: borderColor),
            gradient: LinearGradient(
              colors: [
                background,
                theme.cardColor.withValues(alpha: isDark ? 0.88 : 0.94),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.12),
                blurRadius: 30,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 980;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isCompact) ...[
                    _HeroCopy(
                      bundle: bundle,
                      filters: filters,
                      lastRealtimeSignalAt: lastRealtimeSignalAt,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _SearchControls(
                      searchQuery: searchQuery,
                      searchScope: searchScope,
                      searchStatus: searchStatus,
                      filters: filters,
                      onSearchChanged: onSearchChanged,
                      onScopeChanged: onScopeChanged,
                      onTimeRangeChanged: onTimeRangeChanged,
                    ),
                  ] else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: _HeroCopy(
                            bundle: bundle,
                            filters: filters,
                            lastRealtimeSignalAt: lastRealtimeSignalAt,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xl),
                        Expanded(
                          flex: 6,
                          child: _SearchControls(
                            searchQuery: searchQuery,
                            searchScope: searchScope,
                            searchStatus: searchStatus,
                            filters: filters,
                            onSearchChanged: onSearchChanged,
                            onScopeChanged: onScopeChanged,
                            onTimeRangeChanged: onTimeRangeChanged,
                          ),
                        ),
                      ],
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({
    required this.bundle,
    required this.filters,
    required this.lastRealtimeSignalAt,
  });

  final DashboardBundle bundle;
  final DashboardFilters filters;
  final DateTime? lastRealtimeSignalAt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final liveLabel = lastRealtimeSignalAt == null
        ? 'Waiting for live dashboard signal'
        : 'Live signal ${TimeOfDay.fromDateTime(lastRealtimeSignalAt!).format(context)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _Tag(
              icon: Icons.auto_awesome_rounded,
              label: 'Admin Dashboard',
              color: AppColors.primary,
            ),
            _Tag(
              icon: Icons.bolt_rounded,
              label: liveLabel,
              color: AppColors.secondary,
            ),
            _Tag(
              icon: Icons.cloud_done_rounded,
              label: bundle.isFallback ? 'Seeded local mode' : bundle.sourceLabel,
              color: bundle.isFallback ? AppColors.warning : AppColors.info,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'One command surface for student intake, academic staffing, approvals, and moderation.',
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Search people instantly, watch live enrollment and course movement, then act on uploads and review tasks without leaving the dashboard.',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            _MicroStat(
              icon: Icons.timeline_rounded,
              label: 'Analytics range',
              value: filters.timeRange.label,
            ),
            _MicroStat(
              icon: Icons.update_rounded,
              label: 'Refreshed',
              value:
                  '${bundle.refreshedAt.day}/${bundle.refreshedAt.month}/${bundle.refreshedAt.year}',
            ),
            _MicroStat(
              icon: Icons.pending_actions_rounded,
              label: 'Alerts in queue',
              value: '${bundle.alerts.length} active',
            ),
          ],
        ),
      ],
    );
  }
}

class _SearchControls extends StatelessWidget {
  const _SearchControls({
    required this.searchQuery,
    required this.searchScope,
    required this.searchStatus,
    required this.filters,
    required this.onSearchChanged,
    required this.onScopeChanged,
    required this.onTimeRangeChanged,
  });

  final String searchQuery;
  final DashboardSearchScope searchScope;
  final LoadStatus searchStatus;
  final DashboardFilters filters;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<DashboardSearchScope> onScopeChanged;
  final ValueChanged<DashboardTimeRange> onTimeRangeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search directory',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        _DashboardSearchInput(
          value: searchQuery,
          status: searchStatus,
          onChanged: onSearchChanged,
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final scope in DashboardSearchScope.values)
              ChoiceChip(
                selected: scope == searchScope,
                label: Text(scope.label),
                onSelected: (_) => onScopeChanged(scope),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Chart window',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final range in DashboardTimeRange.values)
              ChoiceChip(
                selected: filters.timeRange == range,
                label: Text(range.label),
                onSelected: (_) => onTimeRangeChanged(range),
              ),
          ],
        ),
      ],
    );
  }
}

class _DashboardSearchInput extends StatefulWidget {
  const _DashboardSearchInput({
    required this.value,
    required this.status,
    required this.onChanged,
  });

  final String value;
  final LoadStatus status;
  final ValueChanged<String> onChanged;

  @override
  State<_DashboardSearchInput> createState() => _DashboardSearchInputState();
}

class _DashboardSearchInputState extends State<_DashboardSearchInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _DashboardSearchInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value == widget.value || _controller.text == widget.value) {
      return;
    }
    _controller.value = TextEditingValue(
      text: widget.value,
      selection: TextSelection.collapsed(offset: widget.value.length),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        hintText: 'Search student, doctor, or assistant',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: widget.status == LoadStatus.loading
            ? const Padding(
                padding: EdgeInsets.all(14),
                child: SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : const Icon(Icons.person_search_rounded),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
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
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _MicroStat extends StatelessWidget {
  const _MicroStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        border: Border.all(
          color: isDark ? AppColors.strokeDark : AppColors.strokeLight,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              Text(value, style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
        ],
      ),
    );
  }
}
