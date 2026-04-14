import 'package:flutter/material.dart';

import 'app_button.dart';

class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 40),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              AppButton(
                label: 'إعادة المحاولة',
                onPressed: onRetry,
                isExpanded: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
