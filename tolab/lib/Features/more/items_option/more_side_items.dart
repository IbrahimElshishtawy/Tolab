// lib/widget/more_side_items.dart

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class MoreSideItems extends StatelessWidget {
  const MoreSideItems({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🧑‍🎓 صورة وأسم المستخدم
        const Center(
          child: CircleAvatar(
            radius: 35,
            backgroundColor: Color(0xFF98ACC9),
            child: Icon(Icons.person, size: 40, color: Colors.white),
          ),
        ),
        const SizedBox(height: 10),

        const Center(
          child: Text(
            'إبراهيم الششتاوي',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 25),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'المزيد من الخيارات',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        const Divider(thickness: 1.1),

        // ✅ أزرار القائمة
        _buildButton(context, Icons.today, 'مواعيد اليوم'),
        _buildButton(context, Icons.folder_open, 'الملفات الجديدة'),
        _buildButton(context, Icons.school, 'مواعيد الكويزات والامتحانات'),
        _buildButton(context, Icons.person, 'الملف الشخصي'),
        _buildButton(context, Icons.info_outline, 'عن التطبيق'),
        _buildButton(context, Icons.logout, 'تسجيل الخروج', color: Colors.red),

        const Spacer(),

        // ✅ الشعار في الأسفل
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'ToL',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(236, 13, 20, 217),
                ),
              ),
              const SizedBox(width: 4),
              Image.asset(
                'assets/image_App/Tolab.png',
                width: 36,
                height: 36,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 4),
              const Text(
                'Ab',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(236, 13, 20, 217),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 🔘 زر أنيق ومسطّح مع أيقونة
  Widget _buildButton(
    BuildContext context,
    IconData icon,
    String title, {
    Color color = Colors.black87,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade100,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: color.withOpacity(0.1)),
            ),
            elevation: 0.8,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          child: Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
