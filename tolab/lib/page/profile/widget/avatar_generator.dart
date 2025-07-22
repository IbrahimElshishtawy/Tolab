import 'package:flutter/material.dart';

class AvatarGenerator extends StatelessWidget {
  final String fullName;
  final double radius;
  final double fontSize;

  const AvatarGenerator({
    super.key,
    required this.fullName,
    this.radius = 24,
    this.fontSize = 16,
  });

  // دالة لاستخراج أول حرف من الاسم الأول و الأخير
  String getInitials(String name) {
    final names = name.trim().split(' ');
    if (names.length == 1) return names[0][0].toUpperCase();
    return names[0][0].toUpperCase() + names.last[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final initials = getInitials(fullName);
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.blueGrey,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
