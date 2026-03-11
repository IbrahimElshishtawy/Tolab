import 'package:flutter/material.dart';
import 'package:tolab_fci/features/home/presentation/widgets/dashboard_shell.dart';

class StudentTodayScheduleCard extends StatelessWidget {
  const StudentTodayScheduleCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardInfoPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Today at a Glance',
                  style: TextStyle(
                    color: Color(0xFF17212F),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '3 sessions',
                style: TextStyle(
                  color: Color(0xFF3469C8),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _ScheduleItem(
            time: '09:00',
            title: 'Software Engineering Lecture',
            place: 'Hall A2',
            color: Colors.indigo,
          ),
          SizedBox(height: 12),
          _ScheduleItem(
            time: '12:30',
            title: 'Database Lab',
            place: 'Lab 3',
            color: Colors.teal,
          ),
          SizedBox(height: 12),
          _ScheduleItem(
            time: '03:00',
            title: 'Community Mentoring Session',
            place: 'Online',
            color: Colors.orange,
          ),
        ],
      ),
    );
  }
}

class _ScheduleItem extends StatelessWidget {
  final String time;
  final String title;
  final String place;
  final Color color;

  const _ScheduleItem({
    required this.time,
    required this.title,
    required this.place,
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
            width: 56,
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
                  place,
                  style: const TextStyle(color: Color(0xFF6C7C92)),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: color),
        ],
      ),
    );
  }
}
