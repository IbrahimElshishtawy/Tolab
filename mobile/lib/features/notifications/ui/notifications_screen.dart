import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../../../redux/app_state.dart';
import '../../../redux/navigation/nav_actions.dart';
import '../../../mock/mock_data.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.builder(
        itemCount: mockNotificationsData.length,
        itemBuilder: (context, index) {
          final data = mockNotificationsData[index];
          return ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(Icons.notifications, color: Colors.white),
            ),
            title: Text(data['title']),
            subtitle: Text(data['message']),
            trailing: const Text('10m ago', style: TextStyle(fontSize: 12)),
            onTap: () {
              if (data['deep_link'] != null) {
                StoreProvider.of<AppState>(context).dispatch(
                  NavigateToDeepLinkAction(data['deep_link']),
                );
              }
            },
          );
        },
      ),
    );
  }
}
