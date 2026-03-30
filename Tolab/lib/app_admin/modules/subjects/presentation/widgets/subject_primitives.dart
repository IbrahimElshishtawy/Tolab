import 'package:flutter/material.dart';

import '../../../../core/animations/app_motion.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../design/subjects_management_tokens.dart';
import '../responsive/subjects_layout.dart';

class SubjectToneBadge extends StatelessWidget {
  const SubjectToneBadge(
    this.label, {
    super.key,
    this.icon,
    this.maxWidth = 140,
  });

  final String label;
  final IconData? icon;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final tone = SubjectsManagementBadges.toneFor(label);
    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: tone.background,
        borderRadius: BorderRadius.circular(AppConstants.pillRadius),
        border: Border.all(color: tone.foreground.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: tone.foreground),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: tone.foreground),
            ),
          ),
        ],
      ),
    );
  }
}

class SubjectInfoPill extends StatelessWidget {
  const SubjectInfoPill({
    super.key,
    required this.label,
    required this.value,
    this.tint,
  });

  final String label;
  final String value;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final color = tint ?? SubjectsManagementPalette.accent;
    return Container(
      constraints: const BoxConstraints(maxWidth: 190),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: SubjectsManagementDecorations.tintedPanel(
        context,
        tint: color,
        opacity: 0.08,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ],
      ),
    );
  }
}

class SubjectMetricTile extends StatelessWidget {
  const SubjectMetricTile({
    super.key,
    required this.label,
    required this.value,
    required this.caption,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final String caption;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      height: 208,
      padding: const EdgeInsets.all(AppSpacing.lg),
      interactive: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: SubjectsManagementDecorations.tintedPanel(
              context,
              tint: color,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}

class SubjectsSegmentedControl<T> extends StatelessWidget {
  const SubjectsSegmentedControl({
    super.key,
    required this.currentValue,
    required this.values,
    required this.labelBuilder,
    required this.onChanged,
  });

  final T currentValue;
  final List<T> values;
  final String Function(T value) labelBuilder;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: SubjectsManagementPalette.muted(context),
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        border: Border.all(color: SubjectsManagementPalette.border(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            for (final value in values)
              _SegmentButton(
                label: labelBuilder(value),
                selected: currentValue == value,
                onTap: () => onChanged(value),
              ),
          ],
        ),
      ),
    );
  }
}

class _SegmentButton extends StatefulWidget {
  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_SegmentButton> createState() => _SegmentButtonState();
}

class _SegmentButtonState extends State<_SegmentButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    final tint = SubjectsManagementPalette.accent;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: AppMotion.fast,
        curve: AppMotion.emphasized,
        decoration: BoxDecoration(
          color: selected
              ? tint.withValues(alpha: 0.12)
              : _hovered
              ? tint.withValues(alpha: 0.06)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.smallRadius),
          border: Border.all(
            color: selected ? tint.withValues(alpha: 0.12) : Colors.transparent,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.smallRadius),
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Text(
              widget.label,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: selected ? tint : null),
            ),
          ),
        ),
      ),
    );
  }
}

class SubjectSectionFrame extends StatelessWidget {
  const SubjectSectionFrame({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  });

  final String title;
  final String subtitle;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppSpacing.md),
                trailing!,
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          child,
        ],
      ),
    );
  }
}

class SubjectAnimatedSwitch extends StatelessWidget {
  const SubjectAnimatedSwitch({
    super.key,
    required this.child,
    required this.switchKey,
  });

  final Widget child;
  final Object switchKey;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.medium,
      switchInCurve: AppMotion.entrance,
      switchOutCurve: AppMotion.emphasized,
      transitionBuilder: (child, animation) {
        final offset = Tween<Offset>(
          begin: const Offset(0, 0.03),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: offset, child: child),
        );
      },
      child: KeyedSubtree(key: ValueKey<Object>(switchKey), child: child),
    );
  }
}

extension SubjectsViewModeLabel on SubjectsViewMode {
  String get label => this == SubjectsViewMode.table ? 'Table View' : 'Grouped';
}
