// lib/core/widgets/loading_indicator.dart

import 'package:flutter/material.dart';

enum LoadingType { circular, linear }

class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color color;
  final LoadingType type;
  final bool center;

  const LoadingIndicator({
    super.key,
    this.size = 30,
    this.color = const Color(0xFF0D14D9),
    this.type = LoadingType.circular,
    this.center = false,
  });

  @override
  Widget build(BuildContext context) {
    final widget = type == LoadingType.circular
        ? SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(color),
              strokeWidth: 3,
            ),
          )
        : LinearProgressIndicator(color: color, minHeight: 4);

    return center ? Center(child: widget) : widget;
  }
}
