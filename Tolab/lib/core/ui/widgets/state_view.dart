import 'package:flutter/material.dart';
import 'loaders.dart';

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
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: List.generate(
            5,
            (index) => const Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: ShimmerLoader(height: 100),
            ),
          ),
        ),
      );
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
            SizedBox(height: 16),
            Text('No data found'),
          ],
        ),
      );
    }

    return child;
  }
}
