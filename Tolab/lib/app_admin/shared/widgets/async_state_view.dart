import 'package:flutter/material.dart';

import '../../core/widgets/app_card.dart';
import '../enums/load_status.dart';

class AsyncStateView extends StatelessWidget {
  const AsyncStateView({
    super.key,
    required this.status,
    required this.child,
    this.errorMessage,
    this.onRetry,
    this.isEmpty = false,
    this.emptyTitle = 'No data yet',
    this.emptySubtitle = 'Connect a source or adjust your filters.',
  });

  final LoadStatus status;
  final Widget child;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final bool isEmpty;
  final String emptyTitle;
  final String emptySubtitle;

  @override
  Widget build(BuildContext context) {
    if (status == LoadStatus.loading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (status == LoadStatus.failure) {
      return AppCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 36),
            const SizedBox(height: 12),
            Text(errorMessage ?? 'Something went wrong'),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (isEmpty) {
      return AppCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, size: 36),
            const SizedBox(height: 12),
            Text(emptyTitle, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(emptySubtitle, textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return child;
  }
}
