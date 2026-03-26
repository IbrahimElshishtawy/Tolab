import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../data/models/admin_models.dart';
import '../controllers/students_controller.dart';

class StudentFormView extends StatefulWidget {
  const StudentFormView({super.key});

  @override
  State<StudentFormView> createState() => _StudentFormViewState();
}

class _StudentFormViewState extends State<StudentFormView> {
  final controller = Get.find<StudentsController>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final departmentController = TextEditingController(text: 'Computer Science');
  final yearController = TextEditingController(text: 'Year 3');
  final batchController = TextEditingController(text: 'CS-2024');
  final gpaController = TextEditingController(text: '3.50');
  String? editingId;

  @override
  void initState() {
    super.initState();
    final id = Get.arguments as String?;
    if (id != null) {
      editingId = id;
      controller.findById(id).then((student) {
        if (student == null) return;
        nameController.text = student.name;
        emailController.text = student.email;
        phoneController.text = student.phone;
        departmentController.text = student.department;
        yearController.text = student.academicYear;
        batchController.text = student.batch;
        gpaController.text = student.gpa.toString();
      });
    }
  }

  Future<void> _save() async {
    final student = StudentModel(
      id: editingId ?? 'ST-${DateTime.now().millisecondsSinceEpoch}',
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      department: departmentController.text.trim(),
      academicYear: yearController.text.trim(),
      batch: batchController.text.trim(),
      gpa: double.tryParse(gpaController.text) ?? 0,
      status: 'active',
      enrolledSubjects: 6,
    );
    await controller.saveStudent(student);
    if (mounted) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                editingId == null ? 'Add Student' : 'Edit Student',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: [
                  SizedBox(
                    width: 320,
                    child: AppTextField(
                      controller: nameController,
                      labelText: 'Full name',
                    ),
                  ),
                  SizedBox(
                    width: 320,
                    child: AppTextField(
                      controller: emailController,
                      labelText: 'Email',
                    ),
                  ),
                  SizedBox(
                    width: 320,
                    child: AppTextField(
                      controller: phoneController,
                      labelText: 'Phone',
                    ),
                  ),
                  SizedBox(
                    width: 320,
                    child: AppTextField(
                      controller: departmentController,
                      labelText: 'Department',
                    ),
                  ),
                  SizedBox(
                    width: 320,
                    child: AppTextField(
                      controller: yearController,
                      labelText: 'Academic year',
                    ),
                  ),
                  SizedBox(
                    width: 320,
                    child: AppTextField(
                      controller: batchController,
                      labelText: 'Batch',
                    ),
                  ),
                  SizedBox(
                    width: 320,
                    child: AppTextField(
                      controller: gpaController,
                      labelText: 'GPA',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(label: 'Save Student', onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}
