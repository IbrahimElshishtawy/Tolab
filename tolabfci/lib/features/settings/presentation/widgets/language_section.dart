import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core\widgets/app_card.dart';
import 'settings_notifier.dart';

class LanguageSection extends ConsumerWidget {
  const LanguageSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsNotifierProvider);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('اللغة', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'التجربة الأساسية عربية، مع تجهيز التوسع للغات إضافية لاحقًا.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _LanguageOption(
                  title: 'العربية',
                  subtitle: 'مفعلة',
                  selected: state.languageCode == 'ar',
                  enabled: true,
                  onTap: () => ref
                      .read(settingsNotifierProvider.notifier)
                      .updateLanguage('ar'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const Expanded(
                child: _LanguageOption(
                  title: 'English',
                  subtitle: 'قريبًا',
                  selected: false,
                  enabled: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.enabled,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: selected ? palette.primarySoft : palette.surfaceAlt,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? Theme.of(context).colorScheme.primary : palette.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
