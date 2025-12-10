// TODO Implement this library.
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../../state/dashboard/dashboard_state.dart';

class DashboardStatCards extends StatelessWidget {
  final DashboardState state;

  const DashboardStatCards({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            label: "Students",
            value: "${state.totalStudents}",
            icon: Icons.people_alt_outlined,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _statCard(
            label: "Doctors",
            value: "${state.totalDoctors}",
            icon: Icons.school_outlined,
            color: Colors.greenAccent,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _statCard(
            label: "Subjects",
            value: "${state.totalSubjects}",
            icon: Icons.menu_book_outlined,
            color: Colors.orangeAccent,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _statCard(
            label: "Pending",
            value: "${state.pendingRequests}",
            icon: Icons.pending_actions_outlined,
            color: Colors.pinkAccent,
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
