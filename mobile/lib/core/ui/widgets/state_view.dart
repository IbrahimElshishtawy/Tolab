import 'package:flutter/material.dart';

class StateView extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final bool isEmpty;
  final Widget child;
  final VoidCallback? onRetry;

  const StateView({
    super.key,
    required this.isLoading,
    this.error,
    this.isEmpty = false,
    required this.child,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(error!, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      );
    }

    if (isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, color: Colors.grey, size: 48),
            const SizedBox(height: 16),
            Text('No data found'),
          ],
        ),
      );
    }

    return child;
  }
}
