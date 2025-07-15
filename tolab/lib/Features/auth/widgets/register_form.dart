// 📁 widgets/register_form.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tolab/Features/auth/controllers/register_controller.dart';

class RegisterForm extends StatelessWidget {
  const RegisterForm({super.key});

  static const List<String> departments = ['AI', 'IT', 'SE', 'CS'];
  static const List<String> studyYears = ['1', '2', '3', '4'];
  static const List<String> userTypes = ['طالب', 'معيد', 'دكتور'];

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<RegisterController>(context);
    final inputBorder = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.blue),
      borderRadius: BorderRadius.circular(8),
    );

    final confirmColor = controller.confirmPasswordController.text.isEmpty
        ? null
        : controller.isPasswordMatched
        ? Colors.blue
        : Colors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'ادخل البيانات المطلوبة في الأسفل',
          style: TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // نوع المستخدم
        Center(
          child: const Text(
            'نوع المستخدم',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Center(
          child: Wrap(
            spacing: 15,
            children: userTypes.map((type) {
              final selected = controller.selectedUserType == type;
              return ChoiceChip(
                label: Text(type),
                selected: selected,
                onSelected: (_) => controller.setUserType(type),
                selectedColor: Colors.blue.shade300,
                backgroundColor: Colors.grey.shade200,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : Colors.black,
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 20),

        // الاسم
        _buildTextField(
          controller.fullNameController,
          'الاسم الرباعي',
          inputBorder,
        ),
        const SizedBox(height: 20),
        // الرقم القومي
        _buildTextField(
          controller.nationalIdController,
          'الرقم القومي',
          inputBorder,
          onChanged: controller.extractNationalIdData,
          keyboardType: TextInputType.number,
        ),

        if (controller.birthDate != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text("تاريخ الميلاد: ${controller.birthDateString}"),
          ),
        if (controller.gender != null) Text("النوع: ${controller.gender}"),
        if (controller.city != null) Text("المحافظة: ${controller.city}"),

        const SizedBox(height: 20),

        // البريد الجامعي
        _buildTextField(
          controller.universityEmailController,
          'البريد الجامعي',
          inputBorder,
          keyboardType: TextInputType.emailAddress,
        ),

        const SizedBox(height: 20),

        if (controller.selectedUserType == 'طالب')
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
                        (dep) => DropdownMenuItem(value: dep, child: Text(dep)),
                      )
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
                    focusedBorder: inputBorder,
                  ),
                  value: controller.selectedStudyYear,
                  items: studyYears
                      .map(
                        (year) =>
                            DropdownMenuItem(value: year, child: Text(year)),
                      )
                      .toList(),
                  onChanged: controller.setStudyYear,
                ),
              ),
            ],
          ),

        const SizedBox(height: 20),

        // البريد الإلكتروني
        _buildTextField(
          controller.emailController,
          'البريد الإلكتروني أو الجيميل',
          inputBorder,
          keyboardType: TextInputType.emailAddress,
        ),

        // كلمة المرور
        _buildPasswordField(
          controller.passwordController,
          'كلمة المرور',
          inputBorder,
          controller.showPassword,
          controller.toggleShowPassword,
        ),

        // تأكيد كلمة المرور
        _buildPasswordField(
          controller.confirmPasswordController,
          'تأكيد كلمة المرور',
          inputBorder.copyWith(
            borderSide: BorderSide(color: confirmColor ?? Colors.grey.shade400),
          ),
          controller.showConfirmPassword,
          controller.toggleShowConfirmPassword,
          confirmColor: confirmColor,
        ),

        const SizedBox(height: 20),

        if (controller.errorMessage != null)
          Text(
            controller.errorMessage!,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),

        const SizedBox(height: 20),

        ElevatedButton(
          onPressed: controller.isLoading
              ? null
              : () async {
                  final success = await controller.register();
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم التسجيل بنجاح!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          controller.errorMessage ?? 'خطأ في التسجيل',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            minimumSize: const Size.fromHeight(55),
            textStyle: const TextStyle(fontSize: 20),
          ),
          child: controller.isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  'إنشاء الحساب',
                  style: TextStyle(color: Colors.white),
                ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    InputBorder border, {
    TextInputType keyboardType = TextInputType.text,
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: border,
        focusedBorder: border,
      ),
    );
  }

  Widget _buildPasswordField(
    TextEditingController controller,
    String label,
    InputBorder border,
    bool isVisible,
    VoidCallback toggleVisibility, {
    Color? confirmColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: TextField(
        controller: controller,
        obscureText: !isVisible,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: IconButton(
            icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
            onPressed: toggleVisibility,
          ),
          border: border,
          focusedBorder: confirmColor != null
              ? OutlineInputBorder(
                  borderSide: BorderSide(color: confirmColor, width: 2),
                )
              : border,
        ),
      ),
    );
  }
}
