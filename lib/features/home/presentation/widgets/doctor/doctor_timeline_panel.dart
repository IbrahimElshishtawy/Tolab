import 'package:flutter/material.dart';
import 'package:tolab_fci/features/home/presentation/widgets/dashboard_shell.dart';

class DoctorTimelinePanel extends StatelessWidget {
  const DoctorTimelinePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardInfoPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today Highlights',
            style: TextStyle(
              color: Color(0xFF17212F),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 16),
          DoctorTimelineTile(
            time: '09:00 AM',
            title: 'Review submissions for CS311',
            subtitle: '18 new uploads pending',
            color: Colors.orange,
          ),
          SizedBox(height: 12),
          DoctorTimelineTile(
            time: '12:00 PM',
            title: 'Database Systems lecture',
            subtitle: 'Hall B1, 85 students enrolled',
            color: Colors.blue,
          ),
          SizedBox(height: 12),
          DoctorTimelineTile(
            time: '03:30 PM',
            title: 'Approve weekly attendance',
            subtitle: 'Finalize session reports',
            color: Colors.green,
          ),
        ],
      ),
    );
  }
}

class DoctorTimelineTile extends StatelessWidget {
  final String time;
  final String title;
  final String subtitle;
  final Color color;

  const DoctorTimelineTile({
    super.key,
    required this.time,
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
            width: 78,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              time,
              textAlign: TextAlign.center,
              style: TextStyle(color: color, fontWeight: FontWeight.w800),
            ),
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
