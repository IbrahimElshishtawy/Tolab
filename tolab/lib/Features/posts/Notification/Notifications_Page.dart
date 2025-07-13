// lib/Features/notifications/pages/notifications_page.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> dummyNotifications = [
      'طلب صداقة جديد من أحمد.',
      'تمت الموافقة على طلبك للانضمام إلى مجموعة Flutter.',
      'لديك تعليق جديد على منشورك.',
      'تم تحديث سياسة الخصوصية.',
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'الإشعارات',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: dummyNotifications.length,
        separatorBuilder: (_, __) => const Divider(color: Colors.grey),
        itemBuilder: (context, index) {
          return ListTile(
            leading: const FaIcon(
              FontAwesomeIcons.solidBell,
              color: Color(0xFF0D14D9),
              size: 20,
            ),
            title: Text(
              dummyNotifications[index],
              style: const TextStyle(fontSize: 14),
            ),
            onTap: () {
              // يمكنك هنا فتح تفاصيل الإشعار
            },
          );
        },
      ),
    );
  }
}
