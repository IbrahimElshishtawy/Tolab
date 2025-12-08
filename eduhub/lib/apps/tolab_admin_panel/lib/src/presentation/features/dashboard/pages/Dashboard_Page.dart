import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tolab Admin Dashboard")),
      body: Center(child: Text("Welcome Admin!")),
    );
  }
}
