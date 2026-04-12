import 'package:flutter/material.dart';

import 'app_button.dart';
import 'app_card.dart';

class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    required this.message,
    this.primaryLabel = 'Close',
    this.onPrimaryPressed,
  });

  final String title;
  final String message;
  final String primaryLabel;
  final VoidCallback? onPrimaryPressed;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: AppCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(message),
            const SizedBox(height: 16),
            AppButton(
              label: primaryLabel,
              onPressed: onPrimaryPressed ?? () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
