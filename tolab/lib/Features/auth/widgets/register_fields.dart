// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:tolab/core/utils/national_id_parser.dart'; // تأكد من المسار الصحيح

class RegisterFields extends StatefulWidget {
  const RegisterFields({super.key});

  @override
  State<RegisterFields> createState() => _RegisterFieldsState();
}

class _RegisterFieldsState extends State<RegisterFields> {
  String role = '';
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  final TextEditingController nationalIdController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  String? birthDate, gender, address;
  bool showDetails = false;

  String? selectedDepartment;
  String? selectedYear;

  final List<String> departments = ['عام', 'IS', 'IT', 'CS', 'AI'];
  final List<String> academicYears = [
    'الأولى',
    'الثانية',
    'الثالثة',
    'الرابعة',
  ];

  InputDecoration inputStyle(String label, {Widget? suffixIcon}) {
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

  void handleNationalIdChange(String value) {
    if (value.length == 14) {
      final birth = NationalIdParser.extractBirthDate(value);
      final gen = NationalIdParser.extractGender(value);
      final city = NationalIdParser.extractCity(value);

      if (birth != null && gen != null && city != null) {
        setState(() {
          birthDate =
              "${birth.day.toString().padLeft(2, '0')}/${birth.month.toString().padLeft(2, '0')}/${birth.year}";
          gender = gen;
          address = city;
          showDetails = true;
        });
      } else {
        setState(() => showDetails = false);
      }
    } else {
      setState(() => showDetails = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              selected: role == 'student',
              onSelected: (_) => setState(() => role = 'student'),
            ),
            ChoiceChip(
              label: const Text("دكتور"),
              selected: role == 'doctor',
              onSelected: (_) => setState(() => role = 'doctor'),
            ),
            ChoiceChip(
              label: const Text("معيد"),
              selected: role == 'assistant',
              onSelected: (_) => setState(() => role = 'assistant'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (role.isNotEmpty) ...[
          TextField(
            controller: nameController,
            decoration: inputStyle("الاسم الكامل"),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: nationalIdController,
            decoration: inputStyle("الرقم القومي"),
            keyboardType: TextInputType.number,
            onChanged: handleNationalIdChange,
          ),
          if (showDetails)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("تاريخ الميلاد: $birthDate"),
                  Text("النوع: $gender"),
                  Text("العنوان: $address"),
                ],
              ),
            ),
          const SizedBox(height: 10),
          TextField(
            controller: emailController,
            decoration: inputStyle("البريد الإلكتروني"),
            keyboardType: TextInputType.emailAddress,
          ),
          if (role == 'student') ...[
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedDepartment,
              items: departments
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (val) => setState(() => selectedDepartment = val),
              decoration: inputStyle("القسم"),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedYear,
              items: academicYears
                  .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                  .toList(),
              onChanged: (val) => setState(() => selectedYear = val),
              decoration: inputStyle("السنة الدراسية"),
            ),
          ],
          const SizedBox(height: 10),
          TextField(
            controller: passwordController,
            obscureText: obscurePassword,
            decoration: inputStyle(
              "كلمة المرور",
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () =>
                    setState(() => obscurePassword = !obscurePassword),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: confirmPasswordController,
            obscureText: obscureConfirmPassword,
            decoration: inputStyle(
              "تأكيد كلمة المرور",
              suffixIcon: IconButton(
                icon: Icon(
                  obscureConfirmPassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () => setState(
                  () => obscureConfirmPassword = !obscureConfirmPassword,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (passwordController.text != confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("كلمتا المرور غير متطابقتين")),
                  );
                  return;
                }

                // ✅ طباعة البيانات في الكونسول
                print("📌 الاسم: ${nameController.text}");
                print("📌 الرقم القومي: ${nationalIdController.text}");
                print("📌 البريد الإلكتروني: ${emailController.text}");
                print("📌 النوع: $gender");
                print("📌 تاريخ الميلاد: $birthDate");
                print("📌 العنوان: $address");
                print("📌 الدور: $role");

                if (role == 'student') {
                  print("📌 القسم: $selectedDepartment");
                  print("📌 السنة الدراسية: $selectedYear");
                }

                // ✅ الانتقال إلى صفحة /home
                Navigator.pushReplacementNamed(context, '/home');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("إنشاء الحساب", style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ],
    );
  }
}
