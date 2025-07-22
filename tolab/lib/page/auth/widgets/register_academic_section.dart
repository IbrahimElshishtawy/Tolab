import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tolab/page/auth/controllers/register_controller.dart';

class RegisterAcademicSection extends StatelessWidget {
  const RegisterAcademicSection({super.key});

  static const List<String> departments = ['AI', 'IT', 'SE', 'CS', 'IS'];
  static const List<String> studyYears = ['1', '2', '3', '4'];

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<RegisterController>(context);
    final inputBorder = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.blue),
      borderRadius: BorderRadius.circular(8),
    );

    if (controller.selectedUserType != 'طالب') return const SizedBox();

    final List<String> currentDepartments = controller.selectedStudyYear == '1'
        ? ['عام', 'AI']
        : departments;

    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'القسم',
              border: inputBorder,
            ),
            value: controller.selectedDepartment,
            items: currentDepartments
                .map((dep) => DropdownMenuItem(value: dep, child: Text(dep)))
                .toList(),
            onChanged: controller.setDepartment,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'السنة الدراسية',
              border: inputBorder,
            ),
            value: controller.selectedStudyYear,
            items: studyYears
                .map((year) => DropdownMenuItem(value: year, child: Text(year)))
                .toList(),
            onChanged: (value) {
              controller.setStudyYear(value!);
              controller.setDepartment(null); // Reset department
            },
          ),
        ),
      ],
    );
  }
}
