import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_segmented_control.dart';
import 'settings_notifier.dart';

class ThemeModeSection extends ConsumerWidget {
  const ThemeModeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsNotifierProvider);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('المظهر', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'اختاري الوضع المناسب للدراسة نهارًا أو ليلًا.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          AppSegmentedControl<ThemeMode>(
            groupValue: state.themeMode,
            onValueChanged: (value) => ref
                .read(settingsNotifierProvider.notifier)
                .updateThemeMode(value),
            children: const {
              ThemeMode.system: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text('تلقائي'),
              ),
              ThemeMode.light: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text('فاتح'),
              ),
              ThemeMode.dark: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text('داكن'),
              ),
            },
          ),
        ],
      ),
    );
  }
}
