import 'package:flutter/material.dart';

class MoreSideItems extends StatelessWidget {
  const MoreSideItems({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final sectionTextColor = isDark
        ? Colors.grey.shade300
        : Colors.grey.shade700;
    final buttonBackground = isDark
        ? Colors.grey.shade800
        : Colors.grey.shade100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ صورة المستخدم
        const Center(
          child: CircleAvatar(
            radius: 35,
            backgroundColor: Color(0xFF98ACC9),
            child: Icon(Icons.person, size: 40, color: Colors.white),
          ),
        ),
        const SizedBox(height: 10),

        // ✅ اسم المستخدم
        Center(
          child: Text(
            'إبراهيم الششتاوي',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
        const SizedBox(height: 25),

        // ✅ عنوان القسم
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'المزيد من الخيارات',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: sectionTextColor,
            ),
          ),
        ),
        Divider(
          thickness: 1.1,
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        ),

        // ✅ الأزرار مرتبة حسب الطلب
        _buildButton(
          context,
          Icons.today,
          'مواعيد اليوم',
          textColor,
          buttonBackground,
        ),
        _buildButton(
          context,
          Icons.folder_open,
          'الملفات الجديدة',
          textColor,
          buttonBackground,
        ),
        _buildButton(
          context,
          Icons.school,
          'مواعيد الكويزات والامتحانات',
          textColor,
          buttonBackground,
        ),
        _buildButton(
          context,
          Icons.menu_book,
          'القرآن الكريم',
          textColor,
          buttonBackground,
        ),
        _buildButton(
          context,
          Icons.info_outline,
          'عن التطبيق',
          textColor,
          buttonBackground,
        ),
        _buildButton(
          context,
          Icons.logout,
          'تسجيل الخروج',
          Colors.red,
          buttonBackground,
        ),

        const Spacer(),

        // ✅ شعار التطبيق
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ToL',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? Colors.lightBlueAccent
                      : const Color.fromARGB(236, 13, 20, 217),
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
              Text(
                'Ab',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? Colors.lightBlueAccent
                      : const Color.fromARGB(236, 13, 20, 217),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 🔘 عنصر زر القائمة
  Widget _buildButton(
    BuildContext context,
    IconData icon,
    String title,
    Color iconColor,
    Color backgroundColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: iconColor.withOpacity(0.1)),
            ),
            elevation: 0.8,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          child: Row(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    color: iconColor,
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
