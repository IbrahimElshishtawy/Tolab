import 'package:flutter/material.dart';

class StudentTopBar extends StatelessWidget {
  final String studentName;

  const StudentTopBar({super.key, required this.studentName});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final formattedDate =
        '${today.day.toString().padLeft(2, '0')}/${today.month.toString().padLeft(2, '0')}/${today.year}';

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: const Color(0xFF020617),
      child: Row(
        children: [
          const Text(
            'Home',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: const Text(
              'Student Desktop',
              style: TextStyle(color: Color(0xFF38BDF8), fontSize: 11),
            ),
          ),
          const Spacer(),
          Text(
            formattedDate,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          ),
          const SizedBox(width: 24),
          IconButton(
            onPressed: () {
              // TODO: افتح شاشة Notifications
            },
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFF1E293B),
            child: Text('S', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 8),
          Text(
            studentName,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
