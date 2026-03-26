import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_spacing.dart';
import '../../../core/widgets/states/state_views.dart';
import '../controllers/students_controller.dart';

class StudentDetailsView extends GetView<StudentsController> {
  const StudentDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final id = Get.arguments as String;
    return FutureBuilder(
      future: controller.findById(id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LoadingStateView();
        }
        final student = snapshot.data!;
        return SingleChildScrollView(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(student.email),
                  const SizedBox(height: AppSpacing.xl),
                  Wrap(
                    spacing: AppSpacing.lg,
                    runSpacing: AppSpacing.lg,
                    children: [
                      _InfoTile(label: 'Phone', value: student.phone),
                      _InfoTile(label: 'Department', value: student.department),
                      _InfoTile(
                        label: 'Academic Year',
                        value: student.academicYear,
                      ),
                      _InfoTile(label: 'Batch', value: student.batch),
                      _InfoTile(
                        label: 'GPA',
                        value: student.gpa.toStringAsFixed(2),
                      ),
                      _InfoTile(
                        label: 'Enrolled Subjects',
                        value: student.enrolledSubjects.toString(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
