import 'package:flutter/material.dart';
import 'package:tolab_fci/features/home/presentation/widgets/dashboard_shell.dart';

class StudentEmptyState extends StatelessWidget {
  const StudentEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardInfoPanel(
      child: Column(
        children: [
          Icon(
            Icons.library_books_outlined,
            size: 42,
            color: Color(0xFF3469C8),
          ),
          SizedBox(height: 12),
          Text(
            'Your subjects will appear here once they are loaded.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF17212F),
            ),
          ),
        ],
      ),
    );
  }
}
