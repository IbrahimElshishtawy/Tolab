import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatelessWidget {
  final String? name;
  final String? email;
  final String? nationalId;
  final String? role;
  final String? department;
  final String? academicYear;

  const ProfilePage({
    super.key,
    this.name,
    this.email,
    this.nationalId,
    this.role,
    this.department,
    this.academicYear,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final photoUrl = user?.photoURL;

    return Scaffold(
      appBar: AppBar(title: const Text('الملف الشخصي')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                  ? NetworkImage(photoUrl)
                  : const AssetImage('assets/images/default_avatar.png')
                        as ImageProvider,
              backgroundColor: Colors.transparent,
            ),
            const SizedBox(height: 16),

            if (name != null && name!.isNotEmpty)
              Text("الاسم: $name", style: const TextStyle(fontSize: 18)),

            if (email != null && email!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                "البريد الإلكتروني: $email",
                style: const TextStyle(fontSize: 18),
              ),
            ],

            if (nationalId != null && nationalId!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                "الرقم القومي: $nationalId",
                style: const TextStyle(fontSize: 18),
              ),
            ],

            if (role == "طالب") ...[
              const SizedBox(height: 8),
              if (department != null)
                Text(
                  "القسم: $department",
                  style: const TextStyle(fontSize: 18),
                ),
              if (academicYear != null)
                Text(
                  "السنة الدراسية: $academicYear",
                  style: const TextStyle(fontSize: 18),
                ),
            ],

            const SizedBox(height: 24),
            const Divider(),

            _buildProfileButton(context, "تعديل البيانات", Icons.edit, () {
              // TODO: اكتب هنا التنقل لصفحة التعديل
            }),

            _buildProfileButton(context, "عرض النتيجة", Icons.bar_chart, () {
              // TODO: اكتب هنا التنقل لصفحة النتيجة
            }),

            _buildProfileButton(context, "سجل التنزيلات", Icons.download, () {
              // TODO: اكتب هنا التنقل لسجل التنزيلات
            }),

            _buildProfileButton(context, "بوستاتي", Icons.post_add, () {
              // TODO: اكتب هنا التنقل لبوستاتي القريبة القادمة
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          backgroundColor: Colors.blueGrey.shade700,
          foregroundColor: Colors.white,
        ),
        icon: Icon(icon),
        label: Text(title, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
