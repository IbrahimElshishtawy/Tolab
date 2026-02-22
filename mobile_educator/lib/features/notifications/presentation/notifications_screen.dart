import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.separated(
        itemCount: 5,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) => ListTile(
          leading: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.notifications, color: Colors.white)),
          title: Text('New Lecture Uploaded #${index + 1}'),
          subtitle: const Text('You have successfully uploaded the lecture manual.'),
          trailing: const Text('10:00 AM', style: TextStyle(fontSize: 10, color: Colors.grey)),
          onTap: () {},
        ),
      ),
    );
  }
}
