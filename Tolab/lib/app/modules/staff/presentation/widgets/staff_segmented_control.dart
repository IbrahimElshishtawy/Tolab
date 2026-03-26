import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../design/staff_management_tokens.dart';

class StaffSegmentedControl extends StatelessWidget {
  const StaffSegmentedControl({
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
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: StaffManagementPalette.muted(context),
        borderRadius: BorderRadius.circular(AppConstants.smallRadius),
        border: Border.all(color: StaffManagementPalette.border(context)),
      ),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: [
          for (final option in options)
            ChoiceChip(
              label: Text(option),
              selected: option == value,
              onSelected: (_) => onChanged(option),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 2,
              ),
            ),
        ],
      ),
    );
  }
}
