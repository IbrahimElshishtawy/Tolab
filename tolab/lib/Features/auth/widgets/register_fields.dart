// ✅ register_fields.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/register_controller.dart';

class RegisterFields extends StatelessWidget {
  const RegisterFields({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<RegisterController>(context);

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.grey),
    );

    final departments = <String>['عام', 'AI', 'CS', 'IS'];
    final studyYears = <String>['أولى', 'ثانية', 'ثالثة', 'رابعة'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // اسم المستخدم
        TextFormField(
          decoration: const InputDecoration(labelText: 'الاسم'),
          controller: controller.fullNameController,
        ),
        const SizedBox(height: 16),

        // البريد
        TextFormField(
          decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
          controller: controller.emailController,
        ),
        const SizedBox(height: 16),

        // كلمة المرور
        TextFormField(
          decoration: const InputDecoration(labelText: 'كلمة المرور'),
          controller: controller.passwordController,
          obscureText: true,
        ),
        const SizedBox(height: 16),

        // القسم والسنة الدراسية
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'القسم',
                  border: inputBorder,
                  focusedBorder: inputBorder,
                ),
                value: controller.selectedDepartment,
                items: departments
                    .map(
                      (dep) => DropdownMenuItem<String>(
                        value: dep,
                        child: Text(dep),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  controller.setDepartment(value!);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'السنة الدراسية',
                  border: inputBorder,
                  focusedBorder: inputBorder,
                ),
                value: controller.selectedStudyYear,
                items: studyYears
                    .map(
                      (year) => DropdownMenuItem<String>(
                        value: year,
                        child: Text(year),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  controller.setStudyYear(value!);
                  // تحديث القسم تلقائيًا إذا السنة الدراسية "أولى"
                  if (value == 'أولى') {
                    controller.setDepartment('عام');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'تم اختيار القسم عام تلقائيًا للسنة الأولى',
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // الزر
        ElevatedButton(
          onPressed: () {
            if (controller.selectedStudyYear == 'أولى' &&
                controller.selectedDepartment != 'عام' &&
                controller.selectedDepartment != 'AI') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('في السنة الأولى يجب أن تكون الشعبة عام أو AI'),
                  backgroundColor: Colors.red,
                ),
              );
            } else {
              controller.register(context);
            }
          },
          child: const Text('إنشاء الحساب'),
        ),
      ],
    );
  }
}
