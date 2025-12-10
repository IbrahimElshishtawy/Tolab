// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../../state/dashboard/dashboard_state.dart';

class StatsCards extends StatelessWidget {
  final DashboardState state;

  const StatsCards({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildCard(
          label: "Students",
          value: state.totalStudents.toString(),
          icon: Icons.people_alt_outlined,
          color: Colors.blueAccent,
        ),
        const SizedBox(width: 16),
        _buildCard(
          label: "Doctors",
          value: state.totalDoctors.toString(),
          icon: Icons.medical_services_outlined,
          color: Colors.greenAccent,
        ),
        const SizedBox(width: 16),
        _buildCard(
          label: "Subjects",
          value: state.totalSubjects.toString(),
          icon: Icons.book_outlined,
          color: Colors.orangeAccent,
        ),
        const SizedBox(width: 16),
        _buildCard(
          label: "Pending",
          value: state.pendingRequests.toString(),
          icon: Icons.pending_actions_outlined,
          color: Colors.pinkAccent,
        ),
      ],
    );
  }

  Widget _buildCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
