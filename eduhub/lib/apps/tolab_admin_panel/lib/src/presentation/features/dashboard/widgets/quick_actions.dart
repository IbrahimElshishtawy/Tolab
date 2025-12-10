// TODO Implement this library.
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _action("Add Student", Icons.person_add, Colors.blue),
        const SizedBox(width: 16),
        _action("Add Subject", Icons.book, Colors.orange),
        const SizedBox(width: 16),
        _action("Schedule", Icons.calendar_month, Colors.green),
        const SizedBox(width: 16),
        _action("Settings", Icons.settings, Colors.purple),
      ],
    );
  }

  Widget _action(String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white.withOpacity(0.07),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
