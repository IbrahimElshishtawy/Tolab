import 'package:flutter/material.dart';

import '../../../../core/spacing/app_spacing.dart';
import 'students_section_card.dart';

class StudentsFeedbackState extends StatelessWidget {
  const StudentsFeedbackState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.action,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return StudentsSectionCard(
      title: title,
      subtitle: subtitle,
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.sm),
          Icon(icon, size: 38),
          const SizedBox(height: AppSpacing.md),
          if (action != null) action!,
        ],
      ),
    );
  }
}
