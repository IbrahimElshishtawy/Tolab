import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';

class ProfileInfoSection extends StatelessWidget {
  const ProfileInfoSection({
    super.key,
    required this.title,
    required this.items,
  });

  final String title;
  final Map<String, String> items;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          ...items.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.key,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  Expanded(child: Text(entry.value)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
