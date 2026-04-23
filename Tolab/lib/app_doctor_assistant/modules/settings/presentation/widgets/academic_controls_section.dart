import 'package:flutter/material.dart';

import '../../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../../presentation/widgets/doctor_assistant_widgets.dart';

class AcademicControlsSection extends StatelessWidget {
  const AcademicControlsSection({
    super.key,
    required this.assignmentWeight,
    required this.midtermWeight,
    required this.oralWeight,
    required this.attendanceWeight,
    required this.finalWeight,
    required this.totalWeight,
    required this.onAssignmentChanged,
    required this.onMidtermChanged,
    required this.onOralChanged,
    required this.onAttendanceChanged,
    required this.onFinalChanged,
  });

  final double assignmentWeight;
  final double midtermWeight;
  final double oralWeight;
  final double attendanceWeight;
  final double finalWeight;
  final double totalWeight;
  final ValueChanged<double> onAssignmentChanged;
  final ValueChanged<double> onMidtermChanged;
  final ValueChanged<double> onOralChanged;
  final ValueChanged<double> onAttendanceChanged;
  final ValueChanged<double> onFinalChanged;

  @override
  Widget build(BuildContext context) {
    return DoctorAssistantPanel(
      title: 'Academic controls',
      subtitle:
          'Distribute grade weights and publication controls with an explicit validation target of 100%.',
      trailing: Chip(label: Text('Total ${totalWeight.round()}%')),
      child: Column(
        children: [
          _WeightSlider(
            label: 'Assignments / coursework',
            value: assignmentWeight,
            onChanged: onAssignmentChanged,
          ),
          _WeightSlider(
            label: 'Midterm',
            value: midtermWeight,
            onChanged: onMidtermChanged,
          ),
          _WeightSlider(
            label: 'Oral',
            value: oralWeight,
            onChanged: onOralChanged,
          ),
          _WeightSlider(
            label: 'Attendance',
            value: attendanceWeight,
            onChanged: onAttendanceChanged,
          ),
          _WeightSlider(
            label: 'Final',
            value: finalWeight,
            onChanged: onFinalChanged,
          ),
        ],
      ),
    );
  }
}

class _WeightSlider extends StatelessWidget {
  const _WeightSlider({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label)),
              Text('${value.round()}%'),
            ],
          ),
          Slider(
            value: value,
            min: 0,
            max: 50,
            divisions: 10,
            label: '${value.round()}%',
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
