import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../app/localization/app_localizations.dart';
import '../design/app_spacing.dart';
import 'app_card.dart';

class LoadingStateView extends StatelessWidget {
  const LoadingStateView({super.key, this.lines = 4});

  final int lines;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      highlightColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: List.generate(
          lines,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: const AppCard(
              child: SizedBox(height: 82, width: double.infinity),
            ),
          ),
        ),
      ),
    );
  }
}

class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.title,
    required this.message,
    this.action,
  });

  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_rounded,
              size: 42,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              context.l10n.byValue(title),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              context.l10n.byValue(message),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (action != null) ...[
              const SizedBox(height: AppSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorStateView extends StatelessWidget {
  const ErrorStateView({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return EmptyStateView(
      title: context.l10n.byValue('Something went wrong'),
      message: context.l10n.byValue(message),
      action: onRetry == null
          ? null
          : FilledButton.tonalIcon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.l10n.t('common.actions.retry')),
            ),
    );
  }
}
