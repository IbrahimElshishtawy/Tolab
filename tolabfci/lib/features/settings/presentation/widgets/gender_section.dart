import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localization.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import 'settings_notifier.dart';

class GenderSection extends ConsumerWidget {
  const GenderSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsNotifierProvider);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('جنس المستخدم (ولد / بنت)', 'User Gender'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            context.tr(
              'تغيير جنس المستخدم لتحديث الأفاتار والاسم الافتراضي بشكل تفاعلي.',
              'Change user gender to update the avatar and default name interactively.',
            ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _GenderOption(
                  title: context.tr('ولد (أزرق)', 'Boy (Blue)'),
                  subtitle: context.tr('ابراهيم خالد', 'Ibrahim Khaled'),
                  selected: state.gender == 'male',
                  icon: Icons.male_rounded,
                  activeColor: AppColors.primary,
                  onTap: () => ref
                      .read(settingsNotifierProvider.notifier)
                      .updateGender('male'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _GenderOption(
                  title: context.tr('بنت (وردي)', 'Girl (Pink)'),
                  subtitle: context.tr('آية خالد', 'Aya Khaled'),
                  selected: state.gender == 'female',
                  icon: Icons.female_rounded,
                  activeColor: Colors.pink,
                  onTap: () => ref
                      .read(settingsNotifierProvider.notifier)
                      .updateGender('female'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GenderOption extends StatelessWidget {
  const _GenderOption({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.icon,
    required this.activeColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final IconData icon;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: selected ? activeColor.withValues(alpha: 0.08) : palette.surfaceAlt,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? activeColor
                : palette.border,
            width: selected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? activeColor : palette.textSecondary,
              size: 28,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                      color: selected ? activeColor : null,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
