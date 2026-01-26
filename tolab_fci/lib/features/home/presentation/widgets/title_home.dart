import 'package:flutter/material.dart';

class TitleHome extends StatelessWidget {
  const TitleHome({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0 , vertical: 8),
      child: Align(
        alignment: AlignmentGeometry.topRight,
        child: Text(
          title,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
        )
      ),
    );
  }
}
