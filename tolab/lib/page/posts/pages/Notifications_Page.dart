// lib/Features/notifications/pages/notifications_page.dart

// ignore_for_file: deprecated_member_use, unnecessary_underscores

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
            return const Center(child: Text("حدث خطأ أثناء تحميل الإشعارات"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
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
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final notif = notifications[index];

              IconData icon;
              Color iconColor;

              switch (notif.type) {
                case 'post':
                  icon = FontAwesomeIcons.solidNewspaper;
                  iconColor = Colors.blueAccent;
                  break;
                case 'file':
                  icon = FontAwesomeIcons.fileAlt;
                  iconColor = Colors.green;
                  break;
                case 'update':
                  icon = FontAwesomeIcons.solidBell;
                  iconColor = Colors.orange;
                  break;
                default:
                  icon = FontAwesomeIcons.infoCircle;
                  iconColor = Colors.grey;
              }

              return ListTile(
                tileColor: isDark ? Colors.grey[900] : Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                leading: FaIcon(icon, color: iconColor),
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
