import 'package:flutter/material.dart';

class AdminScheduleScreen extends StatelessWidget {
  const AdminScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Schedule')),
      body: Center(child: Text('Schedule Editor')),
    );
  }
}
