import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';

class DateSelectorSection extends StatelessWidget {
  const DateSelectorSection({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final dates = List.generate(5, (index) => today.add(Duration(days: index - 1)));

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('This week', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: dates
                .map(
                  (date) => AppBadge(
                    label:
                        '${_weekday(date.weekday)} ${date.day}/${date.month}',
                    backgroundColor: date.day == today.day
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  String _weekday(int value) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[value - 1];
  }
}

