import 'package:flutter/material.dart';
import 'package:tolab_fci/features/home/presentation/widgets/dashboard_shell.dart';

class StudentProgressStrip extends StatelessWidget {
  const StudentProgressStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardInfoPanel(
      child: const Row(
        children: [
          Expanded(
            child: _ProgressMiniCard(
              icon: Icons.task_alt_rounded,
              title: '4/6 done',
              subtitle: 'Weekly goals',
              color: Colors.green,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _ProgressMiniCard(
              icon: Icons.timer_outlined,
              title: '2h 40m',
              subtitle: 'Study time',
              color: Colors.orange,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _ProgressMiniCard(
              icon: Icons.local_fire_department_rounded,
              title: '7 days',
              subtitle: 'Consistency',
              color: Colors.deepPurple,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressMiniCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _ProgressMiniCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBFF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF17212F),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF6C7C92),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
