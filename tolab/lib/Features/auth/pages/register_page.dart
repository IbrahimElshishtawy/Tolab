// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tolab/Features/auth/controllers/register_controller.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  static const List<String> departments = ['AI', 'IT', 'SE', 'CS'];
  static const List<String> studyYears = ['1', '2', '3', '4'];
  static const List<String> userTypes = ['طالب', 'معيد', 'دكتور'];

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.blue),
      borderRadius: BorderRadius.circular(8),
    );

    return ChangeNotifierProvider(
      create: (_) => RegisterController(),
      child: Consumer<RegisterController>(
        builder: (context, controller, _) {
          final confirmColor = controller.confirmPasswordController.text.isEmpty
              ? null
              : controller.isPasswordMatched
              ? Colors.blue
              : Colors.red;

          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: const Text(
                "إنشاء حساب",
                style: TextStyle(color: Colors.black),
              ),
              iconTheme: const IconThemeData(color: Colors.black),
              elevation: 1,
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'ادخل البيانات المطلوبة في الأسفل',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'نوع المستخدم',
                      border: inputBorder,
                      focusedBorder: inputBorder,
                    ),
                    value: controller.selectedUserType ?? userTypes[0],
                    items: userTypes
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                    onChanged: (val) {
                      print('UserType changed to: $val');
                      controller.setUserType(val!);
                    },
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: controller.fullNameController,
                    decoration: InputDecoration(
                      labelText: 'الاسم الرباعي',
                      border: inputBorder,
                      focusedBorder: inputBorder,
                    ),
                    onChanged: (val) {
                      print('FullName changed: $val');
                    },
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: controller.nationalIdController,
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      print('National ID changed: $val');
                      controller.extractNationalIdData(val);
                    },
                    decoration: InputDecoration(
                      labelText: 'الرقم القومي',
                      border: inputBorder,
                      focusedBorder: inputBorder,
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (controller.birthDate != null)
                    Text("تاريخ الميلاد: ${controller.birthDateString}"),
                  if (controller.gender != null)
                    Text("النوع: ${controller.gender}"),
                  if (controller.city != null)
                    Text("المحافظة: ${controller.city}"),

                  const SizedBox(height: 16),

                  TextField(
                    controller: controller.universityEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'البريد الجامعي',
                      border: inputBorder,
                      focusedBorder: inputBorder,
                    ),
                    onChanged: (val) {
                      print('University Email changed: $val');
                    },
                  ),
                  const SizedBox(height: 16),

                  if (controller.selectedUserType == 'طالب') ...[
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'القسم (اختياري)',
                        border: inputBorder,
                        focusedBorder: inputBorder,
                      ),
                      value: controller.selectedDepartment,
                      items: departments
                          .map(
                            (dep) =>
                                DropdownMenuItem(value: dep, child: Text(dep)),
                          )
                          .toList(),
                      onChanged: (val) {
                        print('Department changed: $val');
                        controller.setDepartment(val);
                      },
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'السنة الدراسية',
                        border: inputBorder,
                        focusedBorder: inputBorder,
                      ),
                      value: controller.selectedStudyYear,
                      items: studyYears
                          .map(
                            (year) => DropdownMenuItem(
                              value: year,
                              child: Text(year),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        print('Study Year changed: $val');
                        controller.setStudyYear(val);
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  TextField(
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'البريد الإلكتروني أو الجيميل',
                      border: inputBorder,
                      focusedBorder: inputBorder,
                    ),
                    onChanged: (val) {
                      print('Email changed: $val');
                    },
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: controller.passwordController,
                    obscureText: !controller.showPassword,
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور',
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.showPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          print('Toggle showPassword');
                          controller.toggleShowPassword();
                        },
                      ),
                      border: inputBorder,
                      focusedBorder: inputBorder,
                    ),
                    onChanged: (val) {
                      print('Password changed');
                    },
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: controller.confirmPasswordController,
                    obscureText: !controller.showConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'تأكيد كلمة المرور',
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.showConfirmPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          print('Toggle showConfirmPassword');
                          controller.toggleShowConfirmPassword();
                        },
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: confirmColor ?? Colors.grey.shade400,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: confirmColor ?? Colors.blue,
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (val) {
                      print('Confirm Password changed');
                    },
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
                            print('Start register button pressed');
                            final success = await controller.register();
                            print('Register completed: $success');
                            if (success) {
                              print('User registered successfully!');
                              // يمكن هنا التنقل لصفحة أخرى
                            } else {
                              print(
                                'Registration failed: ${controller.errorMessage}',
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
              ),
            ),
          );
        },
      ),
    );
  }
}
