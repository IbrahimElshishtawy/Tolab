// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class SplashShapesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // ===== Top Left Shapes =====
    paint.color = Colors.white.withOpacity(0.12);
    _drawRotatedRect(
      canvas,
      offset: Offset(-80, -40),
      width: 220,
      height: 220,
      angle: -0.6,
      paint: paint,
    );

    paint.color = Colors.white.withOpacity(0.08);
    _drawRotatedRect(
      canvas,
      offset: Offset(-120, -90),
      width: 260,
      height: 260,
      angle: -0.6,
      paint: paint,
    );

    paint.color = Colors.white.withOpacity(0.05);
    _drawRotatedRect(
      canvas,
      offset: Offset(-160, -140),
      width: 300,
      height: 300,
      angle: -0.6,
      paint: paint,
    );

    // ===== Bottom Right Shapes =====
    paint.color = Colors.white.withOpacity(0.12);
    _drawRotatedRect(
      canvas,
      offset: Offset(size.width - 140, size.height - 140),
      width: 220,
      height: 220,
      angle: -0.6,
      paint: paint,
    );

    paint.color = Colors.white.withOpacity(0.08);
    _drawRotatedRect(
      canvas,
      offset: Offset(size.width - 100, size.height - 100),
      width: 260,
      height: 260,
      angle: -0.6,
      paint: paint,
    );

    paint.color = Colors.white.withOpacity(0.05);
    _drawRotatedRect(
      canvas,
      offset: Offset(size.width - 60, size.height - 60),
      width: 300,
      height: 300,
      angle: -0.6,
      paint: paint,
    );
  }

  void _drawRotatedRect(
    Canvas canvas, {
    required Offset offset,
    required double width,
    required double height,
    required double angle,
    required Paint paint,
  }) {
    canvas.save();
    canvas.translate(offset.dx + width / 2, offset.dy + height / 2);
    canvas.rotate(angle);
    canvas.translate(-width / 2, -height / 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, width, height),
        const Radius.circular(24),
      ),
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
