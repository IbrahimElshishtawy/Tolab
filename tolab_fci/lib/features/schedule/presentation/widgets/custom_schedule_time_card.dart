import 'package:flutter/material.dart';
import 'package:tolab_fci/features/schedule/presentation/widgets/custom_session_card.dart';

class CustomScheduleTimeCard extends StatelessWidget {
  final String time;
  final List<CustomSessionCard> sessions;

  const CustomScheduleTimeCard({
    super.key,
    required this.time,
    required this.sessions,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        // margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xffD7E2F6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            /// Time Row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF023EC5),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.access_time, size: 24, color: Color(0xFF023EC5),),
              ],
            ),
      
            const SizedBox(height: 10),
      
            /// Inner cards (max 3)
            ...sessions.take(3),
          ],
        ),
      ),
    );
  }
}
