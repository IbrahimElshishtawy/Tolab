import 'package:flutter/material.dart';

class ItReportsPanel extends StatelessWidget {
  const ItReportsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        ItReportTile(
          title: 'Report #1024',
          subtitle: 'Pending review by IT',
          color: Colors.deepPurple,
        ),
        SizedBox(height: 12),
        ItReportTile(
          title: 'Report #1025',
          subtitle: 'User access issue detected',
          color: Colors.blue,
        ),
        SizedBox(height: 12),
        ItReportTile(
          title: 'Report #1026',
          subtitle: 'Backup verification required',
          color: Colors.redAccent,
        ),
      ],
    );
  }
}

class ItReportTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;

  const ItReportTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE6ECF6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0E2A47),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.bug_report_outlined, color: color),
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
          Icon(Icons.chevron_right_rounded, color: color),
        ],
      ),
    );
  }
}
