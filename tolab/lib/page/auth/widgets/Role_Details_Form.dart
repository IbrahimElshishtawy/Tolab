// ignore_for_file: use_build_context_synchronously, file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RoleDetailsForm extends StatefulWidget {
  final String role;

  const RoleDetailsForm({super.key, required this.role});

  @override
  State<RoleDetailsForm> createState() => _RoleDetailsFormState();
}

class _RoleDetailsFormState extends State<RoleDetailsForm> {
  final nameController = TextEditingController();
  final nationalIdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? selectedYear;
  String? selectedDepartment;

  bool isSaving = false;

  final List<String> years = [
    'الفرقة الأولى',
    'الفرقة الثانية',
    'الفرقة الثالثة',
    'الفرقة الرابعة',
  ];

  final List<String> departments = [
    'علوم حاسب',
    'نظم معلومات',
    'ذكاء اصطناعي',
    'هندسة برمجيات',
  ];

  @override
  Widget build(BuildContext context) {
    final role = widget.role;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "بيانات ${role == "Student"
              ? "الطالب"
              : role == "Doctor"
              ? "الدكتور"
              : "المعيد"}",
        ),
        centerTitle: true,
        backgroundColor: isDark ? Colors.grey[900] : Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildNameField(role),
              const SizedBox(height: 16),
              _buildNationalIdField(),
              const SizedBox(height: 30),
              if (role == "Student") _buildYearDropdown(),
              if (role == "Student") const SizedBox(height: 16),
              if (role == "Student") _buildDepartmentDropdown(),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 4, 80, 220),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(isSaving ? "جاري الحفظ..." : "حفظ البيانات"),
                onPressed: isSaving ? null : saveData,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameField(String role) {
    return TextFormField(
      controller: nameController,
      decoration: InputDecoration(
        labelText: "الاسم",
        prefixText: role == "Doctor"
            ? "D. "
            : role == "Assistant"
            ? "Eng. "
            : "",
        border: const OutlineInputBorder(),
      ),
      validator: (value) =>
          value!.trim().isEmpty ? "برجاء إدخال الاسم الكامل" : null,
    );
  }

  Widget _buildNationalIdField() {
    return TextFormField(
      controller: nationalIdController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: "الرقم القومي",
        border: OutlineInputBorder(),
      ),
      validator: (value) =>
          value!.length != 14 ? "يجب أن يكون الرقم القومي 14 رقمًا" : null,
    );
  }

  Widget _buildYearDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedYear,
      items: years
          .map((year) => DropdownMenuItem(value: year, child: Text(year)))
          .toList(),
      decoration: const InputDecoration(
        labelText: "السنة الدراسية",
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color.fromARGB(255, 33, 110, 243),
            width: 1.0,
          ),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      onChanged: (value) {
        setState(() => selectedYear = value);
      },
      validator: (value) => value == null ? "اختر السنة الدراسية" : null,
    );
  }

  Widget _buildDepartmentDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedDepartment,
      items: departments
          .map((dep) => DropdownMenuItem(value: dep, child: Text(dep)))
          .toList(),
      decoration: const InputDecoration(
        labelText: "القسم",
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color.fromARGB(255, 33, 110, 243),
            width: 1.0,
          ),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      onChanged: (value) {
        setState(() => selectedDepartment = value);
      },
      validator: (value) => value == null ? "اختر القسم" : null,
    );
  }

  Future<void> saveData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    final user = FirebaseAuth.instance.currentUser;
    final uid = user!.uid;
    final role = widget.role;

    String fullName = nameController.text.trim();
    if (role == "Doctor") fullName = "د. $fullName";
    if (role == "Assistant") fullName = "م. $fullName";

    final data = {
      'uid': uid,
      'name': fullName,
      'email': user.email,
      'role': role,
      'nationalId': nationalIdController.text.trim(),
      'canUploadSummaries': role != 'Student',
    };

    if (role == "Student") {
      data.addAll({'year': selectedYear, 'department': selectedDepartment});
    }

    await FirebaseFirestore.instance.collection('users').doc(uid).set(data);

    Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
  }
}
