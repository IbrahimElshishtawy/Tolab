import 'package:flutter/material.dart';
import 'package:tolab_fci/features/home/presentation/widgets/dashboard_shell.dart';

class StudentOverviewCard extends StatelessWidget {
  final String userName;

  const StudentOverviewCard({
    super.key,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardHeroCard(
      badge: 'Focus Mode',
      badgeIcon: Icons.auto_awesome_rounded,
      title: 'Good progress, $userName',
      description:
          'You are on track this week. Complete the next assignment and review one quiz to keep your streak active.',
      gradient: const [Color(0xFF0E2A47), Color(0xFF225C9C)],
      trailing: const Icon(
        Icons.waving_hand_rounded,
        color: Color(0xFFFFD27A),
      ),
      footer: const [
        HeroMetricChip(value: '84%', label: 'Attendance'),
        HeroMetricChip(value: '3', label: 'Tasks pending'),
        HeroMetricChip(value: '7', label: 'Study streak'),
      ],
    );
  }
}
