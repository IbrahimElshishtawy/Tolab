import 'package:flutter/material.dart';

class PremiumButton extends StatelessWidget {
  const PremiumButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isSecondary = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isSecondary;

  @override
  Widget build(BuildContext context) {
    final style = isSecondary
        ? FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surface,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
          )
        : null;

    return FilledButton.icon(
      onPressed: onPressed,
      style: style,
      icon: Icon(icon ?? Icons.add_rounded, size: 18),
      label: Text(label),
    );
  }
}
