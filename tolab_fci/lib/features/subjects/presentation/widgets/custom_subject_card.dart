import 'package:flutter/material.dart';

class CustomSubjectCard extends StatelessWidget {
  final String title;
  final String year;
  final String batch;
  final String department;
  final String imagePath;
  final Color firstColor;
  final Color secondColor;

  const CustomSubjectCard({
    super.key,
    required this.title,
    required this.year,
    required this.batch,
    required this.department,
    required this.imagePath,
    required this.firstColor,
    required this.secondColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 130,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [firstColor, secondColor],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        children: [
          /// Text Section
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  _infoRow(Icons.calendar_month, year),
                  _infoRow(Icons.group, batch),
                  _infoRow(Icons.bookmark, department),
                ],
              ),
            ),
          ),

          /// Image Section
          SizedBox(
            height: 100,
            width: 100,
            child: CircleAvatar(
              radius: 35,
              backgroundColor: Colors.white,
              backgroundImage: AssetImage(imagePath),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(text, style: TextStyle(color: Colors.white, fontSize: 14)),
          SizedBox(width: 6),
          Icon(icon, size: 16, color: Colors.white),
        ],
      ),
    );
  }
}
