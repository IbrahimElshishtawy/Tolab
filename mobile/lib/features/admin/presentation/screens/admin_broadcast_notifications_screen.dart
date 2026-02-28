import 'package:flutter/material.dart';

class AdminBroadcastNotificationsScreen extends StatelessWidget {
  const AdminBroadcastNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Broadcast')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(decoration: InputDecoration(labelText: 'Notification Title')),
            const SizedBox(height: 16),
            TextField(maxLines: 4, decoration: InputDecoration(labelText: 'Message Body')),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: () {}, child: Text('Send Broadcast')),
          ],
        ),
      ),
    );
  }
}
