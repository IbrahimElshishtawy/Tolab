import 'package:flutter/material.dart';

class AppChip extends StatelessWidget {
  const AppChip({super.key, required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: icon == null ? null : Icon(icon, size: 16),
      label: Text(label),
    );
  }
}
