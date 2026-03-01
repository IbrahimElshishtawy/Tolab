import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';
import '../../../../redux/app_state.dart';
import '../redux/notifications_actions.dart';
import '../redux/notifications_state.dart';
import '../data/models.dart';
import '../../../../core/localization/localization_manager.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, NotificationsState>(
      onInit: (store) => store.dispatch(FetchNotificationsAction()),
      converter: (store) => store.state.notificationsState,
      builder: (context, state) {
        final notifications = state.notifications ?? [];
        return Scaffold(
          appBar: AppBar(title: Text('notifications'.tr())),
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : (notifications.isEmpty
                  ? Center(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        const Text('No notifications yet', style: TextStyle(color: Colors.grey)),
                      ],
                    ))
                  : ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notifData = notifications[index];
                        final notif = notifData is NotificationModel ? notifData : NotificationModel.fromJson(notifData);
                        return _buildNotificationItem(context, notif);
                      },
                    )),
        );
      },
    );
  }

  Widget _buildNotificationItem(BuildContext context, NotificationModel notif) {
    IconData icon;
    Color color;

    switch (notif.type) {
      case 'quiz':
        icon = Icons.quiz;
        color = Colors.purple;
        break;
      case 'lecture':
        icon = Icons.play_lesson;
        color = Colors.orange;
        break;
      case 'section':
        icon = Icons.people;
        color = Colors.green;
        break;
      default:
        icon = Icons.notifications;
        color = Colors.blue;
    }

    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 20),
          ),
          title: Text(notif.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(notif.content),
              const SizedBox(height: 4),
              Text(
                '${notif.dateTime.hour}:${notif.dateTime.minute.toString().padLeft(2, '0')} - ${notif.dateTime.day}/${notif.dateTime.month}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          isThreeLine: true,
          onTap: () {
            if (notif.deepLink != null) {
              context.push(notif.deepLink!);
            }
          },
        ),
        const Divider(height: 1),
      ],
    );
  }
}
