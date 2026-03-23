import 'package:flutter/material.dart';
import 'package:tolab_fci/features/home/presentation/widgets/dashboard_shell.dart';

class ItStatusCard extends StatelessWidget {
  const ItStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardInfoPanel(
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, color: Colors.green),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'System Status: Healthy',
                  style: TextStyle(
                    color: Color(0xFF17212F),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'All core services are operating normally with no critical incidents.',
                  style: TextStyle(color: Color(0xFF6C7C92)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
