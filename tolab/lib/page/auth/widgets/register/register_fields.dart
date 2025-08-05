import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tolab/page/auth/controllers/register/register_cubit.dart';
import 'package:tolab/page/auth/controllers/register/register_state.dart';

class RegisterFields extends StatelessWidget {
  const RegisterFields({super.key});

  InputDecoration inputStyle(
    BuildContext context,
    String label, {
    Widget? suffixIcon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? Colors.grey : Colors.blueGrey),
      ),
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterCubit, RegisterState>(
      listener: (context, state) {
        if (state is RegisterFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is RegisterSuccess) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      },
      builder: (context, state) {
        final cubit = context.read<RegisterCubit>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              children: [
                ChoiceChip(
                  label: const Text("طالب"),
                  selected: cubit.selectedRole == 'student',
                  onSelected: (_) => cubit.setRole('student'),
                ),
                ChoiceChip(
                  label: const Text("دكتور"),
                  selected: cubit.selectedRole == 'doctor',
                  onSelected: (_) => cubit.setRole('doctor'),
                ),
                ChoiceChip(
                  label: const Text("معيد"),
                  selected: cubit.selectedRole == 'assistant',
                  onSelected: (_) => cubit.setRole('assistant'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (cubit.selectedRole != null) ...[
              TextField(
                controller: cubit.fullNameController,
                decoration: inputStyle(context, "الاسم الكامل"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: cubit.nationalIdController,
                decoration: inputStyle(context, "الرقم القومي"),
                keyboardType: TextInputType.number,
                onChanged: cubit.extractNationalIdInfo,
              ),
              if (cubit.gender != null && cubit.birthDate != null) ...[
                const SizedBox(height: 8),
                Text("تاريخ الميلاد: ${cubit.birthDate}"),
                Text("النوع: ${cubit.gender}"),
                Text("العنوان: ${cubit.address ?? 'غير محدد'}"),
              ],
              const SizedBox(height: 10),
              TextField(
                controller: cubit.emailController,
                decoration: inputStyle(context, "البريد الإلكتروني"),
                keyboardType: TextInputType.emailAddress,
              ),
              if (cubit.selectedRole == 'student') ...[
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: cubit.selectedDepartment,
                  items: cubit.departments
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: cubit.setDepartment,
                  decoration: inputStyle(context, "القسم"),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: cubit.selectedStudyYear,
                  items: cubit.academicYears
                      .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                      .toList(),
                  onChanged: cubit.setStudyYear,
                  decoration: inputStyle(context, "السنة الدراسية"),
                ),
              ],
              const SizedBox(height: 10),
              TextField(
                controller: cubit.passwordController,
                obscureText: cubit.obscurePassword,
                decoration: inputStyle(
                  context,
                  "كلمة المرور",
                  suffixIcon: IconButton(
                    icon: Icon(
                      cubit.obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: cubit.togglePasswordVisibility,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: cubit.confirmPasswordController,
                obscureText: cubit.obscureConfirmPassword,
                decoration: inputStyle(
                  context,
                  "تأكيد كلمة المرور",
                  suffixIcon: IconButton(
                    icon: Icon(
                      cubit.obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: cubit.toggleConfirmPasswordVisibility,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => cubit.register(),
                  child: state is RegisterLoading
                      ? const CircularProgressIndicator()
                      : const Text("إنشاء الحساب"),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
