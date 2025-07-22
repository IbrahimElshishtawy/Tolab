// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tolab/page/auth/controllers/login_controller.dart';

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
        // ✅ صورة واسم المستخدم
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/profile');
          },
          child: Column(
            children: [
              const CircleAvatar(
                radius: 35,
                backgroundColor: Color(0xFF98ACC9),
                child: Icon(Icons.person, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                'إبراهيم الششتاوي', // 👈 لو حابب تجيب الاسم من Firebase ممكن تمرره من فوق
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
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

        // ✅ الأزرار
        _buildButton(
          context,
          icon: Icons.folder_open,
          title: 'الملفات الجديدة',
          iconColor: textColor,
          backgroundColor: buttonBackground,
          onTap: () {
            Navigator.pop(context);
            // Navigator.pushNamed(context, '/files');
          },
        ),
        _buildButton(
          context,
          icon: Icons.school,
          title: 'مواعيد الكويزات والامتحانات',
          iconColor: textColor,
          backgroundColor: buttonBackground,
          onTap: () {
            Navigator.pop(context);
            // Navigator.pushNamed(context, '/exams');
          },
        ),
        _buildButton(
          context,
          icon: Icons.menu_book,
          title: 'القرآن الكريم',
          iconColor: textColor,
          backgroundColor: buttonBackground,
          onTap: () {
            Navigator.pop(context);
            // Navigator.pushNamed(context, '/quran');
          },
        ),
        _buildButton(
          context,
          icon: Icons.videogame_asset,
          title: 'الألعاب',
          iconColor: textColor,
          backgroundColor: buttonBackground,
          onTap: () {
            Navigator.pop(context);
            // Navigator.pushNamed(context, '/games');
          },
        ),
        _buildButton(
          context,
          icon: Icons.info_outline,
          title: 'عن التطبيق',
          iconColor: textColor,
          backgroundColor: buttonBackground,
          onTap: () {
            Navigator.pop(context);
            // Navigator.pushNamed(context, '/about');
          },
        ),
        _buildButton(
          context,
          icon: Icons.logout,
          title: 'تسجيل الخروج',
          iconColor: Colors.red,
          backgroundColor: buttonBackground,
          onTap: () async {
            Navigator.pop(context);
            final controller = Provider.of<LoginController>(
              context,
              listen: false,
            );
            await controller.logout(context);
          },
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
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color iconColor,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onTap,
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
