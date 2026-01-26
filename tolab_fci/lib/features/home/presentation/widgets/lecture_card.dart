import 'package:flutter/material.dart';

class LectureCard extends StatelessWidget {
  const LectureCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 15, vertical: 5),
      child: Align(
        alignment: Alignment.topRight,
        child: SingleChildScrollView(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.asset(
                    'assets/images/lecture.png',
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'هندسة البرمجيات',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 6),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.person_outline, size: 16),
                          SizedBox(width: 6),
                          Text('د. أحمد السيد'),
                        ],
                      ),

                      SizedBox(height: 6),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.location_on_outlined, size: 16),
                          SizedBox(width: 4),
                          Text('مدرج 1'),
                          SizedBox(width: 12),
                          Icon(Icons.access_time, size: 16),
                          SizedBox(width: 4),
                          Text('10:00 - 11:30'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
