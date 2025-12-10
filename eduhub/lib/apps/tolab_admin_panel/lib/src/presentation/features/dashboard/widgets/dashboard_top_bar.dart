import 'package:flutter/material.dart';

class DashboardTopBar extends StatelessWidget {
  const DashboardTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          "Tolab Admin Dashboard",
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),

        const Spacer(),

        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.white.withOpacity(0.2),
          child: const Icon(Icons.settings, color: Colors.white),
        ),
      ],
    );
  }
}
