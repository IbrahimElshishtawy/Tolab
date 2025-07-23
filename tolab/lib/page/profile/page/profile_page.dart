import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not logged in');
    }
    return FirebaseFirestore.instance.collection('users').doc(userId).get();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('الملف الشخصي'),
        backgroundColor: isDark
            ? CupertinoColors.black
            : CupertinoColors.systemGrey6,
      ),
      child: SafeArea(
        child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: getUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CupertinoActivityIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('حدث خطأ: ${snapshot.error}'));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('لا توجد بيانات للمستخدم.'));
            }

            final data = snapshot.data!.data()!;
            final name = data['name'] ?? 'غير معروف';
            final email = data['email'] ?? 'لا يوجد بريد';
            final phone = data['phone'] ?? 'لا يوجد رقم';
            final imageUrl = data['imageUrl'];
            final win1 = data['win1'] ?? 0;
            final win2 = data['win2'] ?? 0;
            final win3 = data['win3'] ?? 0;
            final win4 = data['win4'] ?? 0;
            final fail = data['fail'] ?? 0;

            final totalGames = win1 + win2 + win3 + win4 + fail;
            final winRate = totalGames == 0
                ? 0
                : (((win1 + win2 + win3 + win4) / totalGames) * 100)
                      .toStringAsFixed(1);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (imageUrl != null)
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(imageUrl),
                  )
                else
                  const CircleAvatar(
                    radius: 50,
                    child: Icon(CupertinoIcons.person),
                  ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(child: Text(email)),
                const SizedBox(height: 8),
                Center(child: Text(phone)),

                const Divider(height: 32),

                const Text(
                  'إحصائيات لعبة Wordle',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildStatTile('الفوز من أول محاولة', win1),
                _buildStatTile('الفوز من ثاني محاولة', win2),
                _buildStatTile('الفوز من ثالث محاولة', win3),
                _buildStatTile('الفوز من رابع محاولة', win4),
                _buildStatTile('عدد مرات الفشل', fail),
                const SizedBox(height: 12),
                Text('عدد الألعاب: $totalGames'),
                Text('معدل الفوز: $winRate%'),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatTile(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text('$value')],
      ),
    );
  }
}
