// ignore_for_file: file_names, deprecated_member_use

import 'package:flutter/material.dart';

class SplashShapesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double verticalShift = 60; // تحكم في الحركة العمودية

    // 🔼 المجموعة العلوية (نزلناها شوية لتحت)
    _drawGroup(
      canvas,
      baseOffset: const Offset(-140, -140).translate(0, verticalShift),
      angle: -0.55,
      size: const Size(280, 280),
      intensity: 1,
    );

    // 🔽 المجموعة السفلية (طلعناها شوية لفوق)
    _drawGroup(
      canvas,
      baseOffset: Offset(
        size.width - 140,
        size.height - 140,
      ).translate(0, -verticalShift),
      angle: -0.55,
      size: const Size(280, 280),
      intensity: 1,
    );
  }

  void _drawGroup(
    Canvas canvas, {
    required Offset baseOffset,
    required double angle,
    required Size size,
    required int intensity,
  }) {
    // Back layer (shadow)
    _draw3DRect(
      canvas,
      offset: baseOffset.translate(22, 22),
      size: size,
      angle: angle,
      depth: 0.26,
      highlight: false,
    );

    // Middle layer
    _draw3DRect(
      canvas,
      offset: baseOffset.translate(12, 12),
      size: size,
      angle: angle,
      depth: 0.18,
      highlight: true,
    );

    // Front layer
    _draw3DRect(
      canvas,
      offset: baseOffset,
      size: size,
      angle: angle,
      depth: 0.12,
      highlight: true,
    );
  }

  void _draw3DRect(
    Canvas canvas, {
    required Offset offset,
    required Size size,
    required double angle,
    required double depth,
    required bool highlight,
  }) {
    canvas.save();
    canvas.translate(offset.dx + size.width / 2, offset.dy + size.height / 2);
    canvas.rotate(angle);
    canvas.translate(-size.width / 2, -size.height / 2);

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(highlight ? depth + 0.12 : depth),
          Colors.white.withOpacity(depth),
          Colors.white.withOpacity(depth - 0.05),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(rect);

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(28)),
      paint,
    );

    // Highlight edge لإحساس العمق
    if (highlight) {
      final edgePaint = Paint()
        ..color = Colors.white.withOpacity(0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1;

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.deflate(1), const Radius.circular(26)),
        edgePaint,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
