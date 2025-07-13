// lib/widget/more_side_items.dart

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
            backgroundColor: Color.fromRGBO(152, 172, 201, 1),
            child: Icon(Icons.person, size: 40, color: Colors.white),
          ),
        ),
        const SizedBox(height: 10),

        const Center(
          child: Text(
            'إبراهيم الششتاوي',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 30),

        const Text(
          'المزيد من الخيارات',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const Divider(),

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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'ToL',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(236, 13, 20, 217),
                ),
              ),
              const SizedBox(width: 2),
              Image.asset(
                'assets/image_App/Tolab.png',
                width: 50,
                height: 50,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 2),
              const Text(
                'Ab',
                style: TextStyle(
                  fontSize: 30,
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

  /// 🔘 زر بشكل مرتب داخل مساحة كاملة
  Widget _buildButton(
    BuildContext context,
    IconData icon,
    String title, {
    Color color = Colors.black87,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: color,
            elevation: 1,
            shadowColor: Colors.grey.withOpacity(0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: color.withOpacity(0.2)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            alignment: Alignment.centerLeft,
          ),
          icon: Icon(icon, size: 20),
          label: Text(title, style: TextStyle(fontSize: 14, color: color)),
          onPressed: () {
            Navigator.pop(context);
            // TODO: أضف التنقل المناسب هنا
          },
        ),
      ),
    );
  }
}
