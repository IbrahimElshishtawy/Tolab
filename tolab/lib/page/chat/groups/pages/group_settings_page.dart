import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GroupSettingsPage extends StatelessWidget {
  final String groupName;
  final int membersCount;
  final List<String> members;

  const GroupSettingsPage({
    super.key,
    required this.groupName,
    required this.membersCount,
    required this.members,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('إعدادات الجروب'),
        backgroundColor: isDark ? CupertinoColors.black : CupertinoColors.white,
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage(
                      'assets/image_App/Tolab.png',
                    ), // غيره لو عندك صورة مختلفة
                  ),
                  const SizedBox(height: 12),
                  Text(
                    groupName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$membersCount عضو',
                    style: TextStyle(
                      color: CupertinoColors.systemGrey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  CupertinoButton.filled(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: const Text('تعديل اسم الجروب'),
                    onPressed: () {
                      // أكشن تعديل الاسم
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'الأعضاء:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            ...members.map(
              (name) => Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? CupertinoColors.systemGrey5
                      : CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.person_crop_circle),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(name, style: const TextStyle(fontSize: 15)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            CupertinoButton(
              color: CupertinoColors.destructiveRed,
              child: const Text('الخروج من الجروب'),
              onPressed: () {
                // أكشن الخروج من الجروب
              },
            ),
          ],
        ),
      ),
    );
  }
}
