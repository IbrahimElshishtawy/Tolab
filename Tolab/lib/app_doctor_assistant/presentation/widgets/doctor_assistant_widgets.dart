import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app_admin/core/colors/app_colors.dart';
import '../../../app_admin/core/constants/app_constants.dart';
import '../../../app_admin/core/responsive/app_breakpoints.dart';
import '../../../app_admin/core/spacing/app_spacing.dart';
import '../../../app_admin/core/widgets/app_card.dart';
import '../../../app_admin/core/widgets/page_header.dart';
import '../../../app_admin/modules/content_management/presentation/widgets/admin_form.dart';
import '../../../app_admin/shared/widgets/premium_button.dart';
import '../../../app_admin/shared/widgets/status_badge.dart';
import '../../models/doctor_assistant_models.dart';

class DoctorAssistantPageScaffold extends StatelessWidget {
  const DoctorAssistantPageScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.actions = const <Widget>[],
    this.breadcrumbs = const <String>[],
    this.scrollable = true,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final List<Widget> actions;
  final List<String> breadcrumbs;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final header = PageHeader(
      title: title,
      subtitle: subtitle,
      actions: actions,
      breadcrumbs: breadcrumbs,
    );

    if (scrollable) {
      return SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            const SizedBox(height: AppSpacing.md),
            child,
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        const SizedBox(height: AppSpacing.md),
        Expanded(child: child),
      ],
    );
  }
}

class DoctorAssistantSummaryStrip extends StatelessWidget {
  const DoctorAssistantSummaryStrip({super.key, required this.metrics});

  final List<WorkspaceOverviewMetric> metrics;

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(context);
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        for (final metric in metrics)
          SizedBox(
            width: isMobile ? double.infinity : 240,
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color: metric.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(metric.icon, color: metric.color),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(metric.label, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    metric.value,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    metric.caption,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class DoctorAssistantPanel extends StatelessWidget {
  const DoctorAssistantPanel({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppSpacing.md),
                trailing!,
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          child,
        ],
      ),
    );
  }
}

class DoctorAssistantItemCard extends StatelessWidget {
  const DoctorAssistantItemCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.statusLabel,
    this.onTap,
    this.trailing,
    this.highlightColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String meta;
  final String statusLabel;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    final accent = highlightColor ?? AppColors.primary;
    return AppCard(
      interactive: onTap != null,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    StatusBadge(statusLabel),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(meta, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.sm),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class DoctorAssistantSubjectCard extends StatelessWidget {
  const DoctorAssistantSubjectCard({
    super.key,
    required this.subject,
    required this.onTap,
  });

  final TeachingSubject subject;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      interactive: true,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: subject.accentColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            subject.code,
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: subject.accentColor,
                            ),
                          ),
                        ),
                        StatusBadge('${subject.studentCount} students'),
                        StatusBadge('${subject.sectionCount} sections'),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      subject.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subject.academicTerm,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            subject.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.pillRadius),
            child: LinearProgressIndicator(
              value: subject.progress,
              minHeight: 8,
              backgroundColor: subject.accentColor.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(subject.accentColor),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${(subject.progress * 100).round()}% delivery progress',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class DoctorAssistantQuickActionGrid extends StatelessWidget {
  const DoctorAssistantQuickActionGrid({
    super.key,
    required this.actions,
  });

  final List<WorkspaceQuickAction> actions;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        for (final action in actions)
          SizedBox(
            width: AppBreakpoints.isMobile(context) ? double.infinity : 232,
            child: AppCard(
              interactive: true,
              onTap: () => context.go(action.route),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(action.icon, color: AppColors.primary),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(action.title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    action.subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class DoctorAssistantEmptyState extends StatelessWidget {
  const DoctorAssistantEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 68,
                width: 68,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.inbox_rounded,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DoctorAssistantFormLayout extends StatelessWidget {
  const DoctorAssistantFormLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.formKey,
    required this.children,
    required this.primaryLabel,
    required this.onSubmit,
    this.secondaryLabel,
    this.onSecondaryTap,
    this.maxWidth = 980,
  });

  final String title;
  final String subtitle;
  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  final String primaryLabel;
  final VoidCallback onSubmit;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryTap;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: AdminForm(
          title: title,
          subtitle: subtitle,
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...children,
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    PremiumButton(
                      label: primaryLabel,
                      icon: Icons.check_rounded,
                      onPressed: onSubmit,
                    ),
                    if (secondaryLabel != null)
                      PremiumButton(
                        label: secondaryLabel!,
                        icon: Icons.arrow_back_rounded,
                        isSecondary: true,
                        onPressed: onSecondaryTap,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
