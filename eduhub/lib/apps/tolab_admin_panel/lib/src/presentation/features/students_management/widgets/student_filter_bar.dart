import 'package:flutter/material.dart';

class StudentFilterBar extends StatelessWidget {
  final String? selectedDepartment;
  final int? selectedYear;
  final String? selectedName; // حقل اسم الطالب
  final ValueChanged<String?> onDepartmentChange;
  final ValueChanged<int?> onYearChange;
  final ValueChanged<String?> onNameChange; // دالة تغيير اسم الطالب

  const StudentFilterBar({
    super.key,
    required this.selectedDepartment,
    required this.selectedYear,
    required this.onDepartmentChange,
    required this.onYearChange,
    required this.onNameChange, // تمرير الدالة للبحث عن الاسم
    this.selectedName,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // توزيع الفلاتر
      children: [
        // حقل للبحث عن القسم
        _buildTextField(
          label: "القسم",
          initialValue: selectedDepartment,
          onChanged: onDepartmentChange,
        ),
        const SizedBox(width: 16), // المسافة بين الفلاتر
        // حقل للبحث عن السنة الدراسية
        _buildTextField(
          label: "السنة الدراسية",
          initialValue: selectedYear?.toString(),
          onChanged: (value) => onYearChange(int.tryParse(value ?? '')),
        ),
        const SizedBox(width: 16), // المسافة بين الفلاتر
        // حقل للبحث عن اسم الطالب
        _buildTextField(
          label: "اسم الطالب",
          initialValue: selectedName,
          onChanged: onNameChange, // تعديل البيانات عند تغيير الاسم
        ),
      ],
    );
  }

  // دالة لبناء حقل النص
  Widget _buildTextField({
    required String label,
    required String? initialValue,
    required ValueChanged<String?> onChanged,
  }) {
    return Expanded(
      // لضمان التوزيع المتساوي
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            onChanged: onChanged,
            controller: TextEditingController(text: initialValue),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              hintText: 'أدخل $label',
              hintStyle: TextStyle(color: Colors.white54),
            ),
          ),
        ],
      ),
    );
  }
}
