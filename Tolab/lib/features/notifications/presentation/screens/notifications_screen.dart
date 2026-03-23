import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.notifications, color: Colors.white)),
            title: Text('New Material in CS101'),
            subtitle: Text('Dr. Ahmed uploaded Lecture 3'),
            trailing: const Text('10m ago', style: TextStyle(fontSize: 12)),
            onTap: () {},
          );
        },
      ),
    );
  }
}
