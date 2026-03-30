import 'package:flutter/material.dart';

import '../../../../core/animations/app_motion.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../design/students_admin_tokens.dart';

class StudentsSegmentedControl extends StatelessWidget {
  const StudentsSegmentedControl({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final List<String> options;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: StudentsAdminPalette.muted(context),
          borderRadius: BorderRadius.circular(AppConstants.smallRadius),
          border: Border.all(color: StudentsAdminPalette.border(context)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in options)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _SegmentOption(
                  label: option,
                  selected: option == value,
                  onTap: () => onChanged(option),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SegmentOption extends StatelessWidget {
  const _SegmentOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.fast,
      curve: AppMotion.emphasized,
      decoration: BoxDecoration(
        color: selected
            ? StudentsAdminPalette.surface(context)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppConstants.smallRadius - 4),
        boxShadow: selected
            ? StudentsAdminDecorations.softShadow(context)
            : null,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.smallRadius - 4),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: selected
                  ? Theme.of(context).colorScheme.onSurface
                  : StudentsAdminPalette.subtleText(context),
            ),
          ),
        ),
      ),
    );
  }
}
