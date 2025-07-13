// lib/widget/more_side_items.dart

import 'package:flutter/material.dart';

class MoreSideItems extends StatelessWidget {
  const MoreSideItems({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 🧑‍🎓 صورة وأسم المستخدم
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

        /// ✅ عناصر القائمة
        _buildTile(Icons.today, 'مواعيد اليوم', context),
        _buildTile(Icons.folder_open, 'الملفات الجديدة', context),
        _buildTile(Icons.school, 'مواعيد الكويزات والامتحانات', context),
        _buildTile(Icons.person, 'الملف الشخصي', context),
        _buildTile(Icons.info_outline, 'عن التطبيق', context),
        _buildTile(
          Icons.logout,
          'تسجيل الخروج',
          context,
          iconColor: Colors.red,
        ),

        const Spacer(),

        /// ✅ الشعار في الأسفل
        Center(
          child: Column(
            children: [
              Image.asset(
                'assets/image_App/Tolab.png',
                width: 60,
                height: 60,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 6),
              const Text(
                'ToLab',
                style: TextStyle(
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

  /// 🔧 تبسيط إنشاء البلاطات
  Widget _buildTile(
    IconData icon,
    String title,
    BuildContext context, {
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.black87),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        // TODO: اضف التنقل المناسب هنا
      },
    );
  }
}
