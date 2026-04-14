import 'package:flutter/material.dart';

import '../../../../core/models/student_profile.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';

class AcademicInfoCard extends StatelessWidget {
  const AcademicInfoCard({super.key, required this.profile});

  final StudentProfile profile;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Academic overview',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.md,
            children: [
              _Meta(label: 'Faculty', value: profile.faculty),
              _Meta(label: 'Department', value: profile.department),
              _Meta(label: 'Advisor', value: profile.academicAdvisor),
              _Meta(label: 'Seat number', value: profile.seatNumber),
            ],
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(value),
        ],
      ),
    );
  }
}
