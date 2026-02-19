import 'package:flutter/material.dart';

class CustomSessionCard extends StatelessWidget {
  final String title;
  final String doctor;
  final String room;

  const CustomSessionCard({
    super.key,
    required this.title,
    required this.doctor,
    required this.room,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style:  TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),

          _infoRow(Icons.person_outline, doctor),
          _infoRow(Icons.location_on_outlined, room),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            text,
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
          const SizedBox(width: 6),
          Icon(icon, size: 14, color: Colors.black),
        ],
      ),
    );
  }
}