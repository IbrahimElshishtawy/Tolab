// ignore_for_file: deprecated_member_use

import 'package:eduhub/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../../../../state/app_state.dart';
import '../../../../state/students/students_actions.dart';
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
            context: context,
            label: "Students",
            value: "${state.totalStudents}",
            icon: Icons.people_alt_outlined,
            color: Colors.blueAccent,
            onTap: () {
              StoreProvider.of<AppState>(
                context,
              ).dispatch(LoadStudentsAction());

              Navigator.pushNamed(context, AppRoutes.students);
            },
          ),
        ),
        const SizedBox(width: 16),

        Expanded(
          child: _statCard(
            context: context,
            label: "Doctors",
            value: "${state.totalDoctors}",
            icon: Icons.school_outlined,
            color: Colors.greenAccent,
            onTap: () {},
          ),
        ),
        const SizedBox(width: 16),

        Expanded(
          child: _statCard(
            context: context,
            label: "Subjects",
            value: "${state.totalSubjects}",
            icon: Icons.menu_book_outlined,
            color: Colors.orangeAccent,
            onTap: () {},
          ),
        ),
        const SizedBox(width: 16),

        Expanded(
          child: _statCard(
            context: context,
            label: "Pending",
            value: "${state.pendingRequests}",
            icon: Icons.pending_actions_outlined,
            color: Colors.pinkAccent,
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white10),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 14,
              spreadRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
