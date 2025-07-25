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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'ملفي التعليمي',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                  ? NetworkImage(photoUrl)
                  : const AssetImage('assets/images/default_avatar.png')
                        as ImageProvider,
              backgroundColor: Colors.grey[800],
            ),
            const SizedBox(height: 16),

            Text(
              name ?? "اسم المستخدم",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              email ?? "البريد الإلكتروني",
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),

            const SizedBox(height: 24),
            const Divider(color: Colors.white),

            if (role == "طالب") ...[
              _infoRow("الرقم القومي", nationalId),
              _infoRow("القسم", department),
              _infoRow("السنة الدراسية", academicYear),
            ],

            const SizedBox(height: 32),

            _sectionTitle("📖 قراءة القرآن"),
            _progressBar(title: "التقدم", value: 0.65), // 65%

            const SizedBox(height: 24),

            _sectionTitle("🎮 التقدم في اللعب التعليمية"),
            _progressBar(title: "مستواك الحالي", value: 0.4), // 40%

            const SizedBox(height: 32),

            _buildProfileButton(context, "تعديل البيانات", Icons.edit, () {
              // TODO: تنقل لصفحة التعديل
            }),
            _buildProfileButton(context, "عرض النتيجة", Icons.school, () {
              // TODO: عرض النتائج
            }),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            "$label:",
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(width: 10),
          Text(value, style: TextStyle(color: Colors.grey[300], fontSize: 16)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.amber,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _progressBar({required String title, required double value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 12,
            backgroundColor: Colors.grey[800],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "${(value * 100).toInt()}%",
          style: const TextStyle(color: Colors.white),
        ),
      ],
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
        icon: Icon(icon),
        label: Text(title),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueGrey.shade900,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
