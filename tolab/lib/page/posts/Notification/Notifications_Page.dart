// lib/Features/notifications/pages/notifications_page.dart

// ignore_for_file: unnecessary_underscores

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/notification_model.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        centerTitle: true,
        backgroundColor:
            theme.appBarTheme.backgroundColor ?? theme.primaryColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("حدث خطأ"));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data!.docs.map((doc) {
            return AppNotification.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();

          if (notifications.isEmpty) {
            return const Center(child: Text("لا توجد إشعارات حالياً."));
          }

          return ListView.separated(
            itemCount: notifications.length,
            padding: const EdgeInsets.all(16),
            separatorBuilder: (_, __) =>
                Divider(color: isDark ? Colors.grey[700] : Colors.grey[300]),
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return ListTile(
                tileColor: isDark ? Colors.grey[900] : Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                leading: FaIcon(
                  FontAwesomeIcons.solidBell,
                  color: isDark ? Colors.amberAccent : const Color(0xFF0D14D9),
                ),
                title: Text(
                  notif.title,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  notif.content,
                  style: TextStyle(
                    color: isDark ? Colors.grey[300] : Colors.black87,
                  ),
                ),
                onTap: () {
                  // التنقل حسب نوع الإشعار
                  if (notif.type == 'post') {
                    Navigator.pushNamed(
                      context,
                      '/postDetails',
                      arguments: notif.referenceId,
                    );
                  } else if (notif.type == 'file') {
                    Navigator.pushNamed(
                      context,
                      '/fileView',
                      arguments: notif.referenceId,
                    );
                  } else if (notif.type == 'update') {
                    Navigator.pushNamed(
                      context,
                      '/updateDetails',
                      arguments: notif.referenceId,
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
