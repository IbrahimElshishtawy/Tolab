import 'package:flutter/material.dart';

import '../../core/spacing/app_spacing.dart';

class EntityFormSheet extends StatelessWidget {
  const EntityFormSheet({
    super.key,
    required this.title,
    required this.children,
    this.onSubmit,
    this.submitLabel = 'Save',
  });

  final String title;
  final List<Widget> children;
  final VoidCallback? onSubmit;
  final String submitLabel;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.lg),
            ...children,
            const SizedBox(height: AppSpacing.lg),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: onSubmit,
                child: Text(submitLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
