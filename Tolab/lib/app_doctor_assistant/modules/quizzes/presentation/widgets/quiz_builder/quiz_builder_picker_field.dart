import 'package:flutter/material.dart';

import '../../../../dashboard/presentation/theme/dashboard_theme_tokens.dart';
import '../../../../../core/design/app_spacing.dart';

class QuizBuilderPickerField extends StatelessWidget {
  const QuizBuilderPickerField({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: Icon(icon, color: tokens.primary),
        ),
        child: Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: tokens.textPrimary),
        ),
      ),
    );
  }
}
