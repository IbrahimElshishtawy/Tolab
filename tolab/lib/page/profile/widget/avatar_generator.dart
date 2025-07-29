import 'package:flutter/material.dart';

class AvatarGenerator extends StatelessWidget {
  final String name;
  final double radius;
  final double fontSize;

  const AvatarGenerator({
    super.key,
    required this.name,
    this.radius = 24,
    this.fontSize = 16,
  });

  // دالة لاستخراج أول حرفين من الاسم (سواء للمستخدم أو الجروب)
  String getInitials(String name) {
    final cleanedName = name.trim();
    if (cleanedName.length <= 2) return cleanedName.toUpperCase();

    final names = cleanedName.split(' ');
    if (names.length == 1) {
      return cleanedName.substring(0, 2).toUpperCase();
    } else {
      // أول حرف من أول اسم + أول حرف من آخر اسم
      return (names.first[0] + names.last[0]).toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final initials = getInitials(name);
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
