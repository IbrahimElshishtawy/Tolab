// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/register_controller.dart';

class RegisterFields extends StatelessWidget {
  const RegisterFields({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<RegisterController>(context);
    final theme = Theme.of(context);

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.grey),
    );

    final departments = ['عام', 'AI', 'CS', 'IS'];
    final studyYears = ['أولى', 'ثانية', 'ثالثة', 'رابعة'];
    final roles = ['دكتور', 'معيد', 'طالب'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // الاسم
        TextFormField(
          controller: controller.fullNameController,
          decoration: InputDecoration(labelText: 'الاسم', border: inputBorder),
        ),
        const SizedBox(height: 12),

        // البريد
        TextFormField(
          controller: controller.emailController,
          decoration: InputDecoration(
            labelText: 'البريد الإلكتروني',
            border: inputBorder,
          ),
        ),
        const SizedBox(height: 12),

        // الرقم القومي
        TextFormField(
          controller: controller.nationalIdController,
          decoration: InputDecoration(
            labelText: 'الرقم القومي',
            border: inputBorder,
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            if (value.length >= 14) {
              controller.extractNationalIdInfo(value);
            }
          },
        ),
        const SizedBox(height: 12),

        // تاريخ الميلاد
        TextFormField(
          readOnly: true,
          controller: controller.birthDateController,
          decoration: InputDecoration(
            labelText: 'تاريخ الميلاد',
            border: inputBorder,
          ),
        ),
        const SizedBox(height: 12),

        // النوع
        TextFormField(
          readOnly: true,
          controller: controller.genderController,
          decoration: InputDecoration(labelText: 'النوع', border: inputBorder),
        ),
        const SizedBox(height: 12),

        // العنوان
        TextFormField(
          readOnly: true,
          controller: controller.addressController,
          decoration: InputDecoration(
            labelText: 'العنوان',
            border: inputBorder,
          ),
        ),
        const SizedBox(height: 12),

        // كلمة المرور
        TextFormField(
          controller: controller.passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'كلمة المرور',
            border: inputBorder,
          ),
        ),
        const SizedBox(height: 12),

        // تأكيد كلمة المرور
        TextFormField(
          controller: controller.confirmPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'تأكيد كلمة المرور',
            border: inputBorder,
            suffixIcon: controller.passwordsMatch
                ? const Icon(Icons.check, color: Colors.green)
                : const Icon(Icons.close, color: Colors.red),
          ),
          onChanged: (val) {
            controller.checkPasswordMatch();
          },
        ),
        const SizedBox(height: 12),

        // الدور (دكتور / معيد / طالب)
        DropdownButtonFormField<String>(
          decoration: InputDecoration(labelText: 'النوع', border: inputBorder),
          value: controller.selectedRole,
          items: roles
              .map((r) => DropdownMenuItem(value: r, child: Text(r)))
              .toList(),
          onChanged: (value) => controller.setRole(value!),
        ),
        const SizedBox(height: 12),

        // السنة الدراسية + القسم
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'القسم',
                  border: inputBorder,
                ),
                value: controller.selectedDepartment,
                items: departments
                    .map(
                      (dep) => DropdownMenuItem(value: dep, child: Text(dep)),
                    )
                    .toList(),
                onChanged: (value) => controller.setDepartment(value!),
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
                    .map(
                      (year) =>
                          DropdownMenuItem(value: year, child: Text(year)),
                    )
                    .toList(),
                onChanged: (value) {
                  controller.setStudyYear(value!);
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
        const SizedBox(height: 20),

        ElevatedButton(
          onPressed: () {
            if (!controller.passwordsMatch) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('كلمتا المرور غير متطابقتين'),
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
