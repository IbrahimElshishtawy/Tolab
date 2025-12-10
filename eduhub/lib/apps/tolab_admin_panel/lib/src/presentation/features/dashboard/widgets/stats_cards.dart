// ignore_for_file: deprecated_member_use

import 'package:eduhub/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../../../../state/app_state.dart';
import '../../../../state/students/students_actions.dart';

import '../../../../state/dashboard/dashboard_state.dart';

class StatsCards extends StatelessWidget {
  final DashboardState state;

  const StatsCards({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildCard(
          context: context,
          label: "Students",
          value: state.totalStudents.toString(),
          icon: Icons.people_alt_outlined,
          color: Colors.blueAccent,
          onTap: () {
            StoreProvider.of<AppState>(context).dispatch(LoadStudentsAction());
            Navigator.pushNamed(context, AppRoutes.students);
          },
        ),
        const SizedBox(width: 16),

        _buildCard(
          context: context,
          label: "Doctors",
          value: state.totalDoctors.toString(),
          icon: Icons.medical_services_outlined,
          color: Colors.greenAccent,
          onTap: () {},
        ),
        const SizedBox(width: 16),

        _buildCard(
          context: context,
          label: "Subjects",
          value: state.totalSubjects.toString(),
          icon: Icons.book_outlined,
          color: Colors.orangeAccent,
          onTap: () {},
        ),
        const SizedBox(width: 16),

        _buildCard(
          context: context,
          label: "Pending",
          value: state.pendingRequests.toString(),
          icon: Icons.pending_actions_outlined,
          color: Colors.pinkAccent,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white10),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
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
        ),
      ),
    );
  }
}
