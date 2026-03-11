import 'package:flutter/material.dart';
import 'package:tolab_fci/features/home/presentation/widgets/dashboard_shell.dart';

class TaQueuePanel extends StatelessWidget {
  const TaQueuePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardInfoPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lab Queue',
            style: TextStyle(
              color: Color(0xFF17212F),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 16),
          TaQueueTile(
            title: 'Programming Lab submissions',
            subtitle: '12 assignments require feedback',
            color: Colors.teal,
          ),
          SizedBox(height: 12),
          TaQueueTile(
            title: 'Student clarification requests',
            subtitle: '5 new unresolved questions',
            color: Colors.indigo,
          ),
          SizedBox(height: 12),
          TaQueueTile(
            title: 'Attendance reconciliation',
            subtitle: 'Session CS201-L2 still open',
            color: Colors.deepOrange,
          ),
        ],
      ),
    );
  }
}

class TaQueueTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;

  const TaQueueTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE6ECF6)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.circle_notifications_rounded, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  style: const TextStyle(color: Color(0xFF6C7C92)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
