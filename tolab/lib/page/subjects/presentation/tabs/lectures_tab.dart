import 'package:flutter/material.dart';

class LecturesTab extends StatelessWidget {
  const LecturesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'محاضرات المادة',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
