import 'package:flutter/material.dart';

class DevQuickLoginButton extends StatelessWidget {
  const DevQuickLoginButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: Icon(
          isLoading ? Icons.hourglass_top_rounded : Icons.bolt_rounded,
          size: 16,
        ),
        label: Text(
          isLoading ? 'Creating test account...' : 'Dev: Create Test Account',
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurfaceVariant,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          side: BorderSide(color: colorScheme.outlineVariant),
          textStyle: textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
        ),
      ),
    );
  }
}
