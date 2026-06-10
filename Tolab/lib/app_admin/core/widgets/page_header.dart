import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/localization/app_localizations.dart';
import '../colors/app_colors.dart';
import '../responsive/app_breakpoints.dart';
import '../spacing/app_spacing.dart';
import '../routing/route_paths.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.actions = const [],
    this.breadcrumbs = const [],
  });

  final String title;
  final String subtitle;
  final List<Widget> actions;
  final List<String> breadcrumbs;

  String? _getRoutePath(String label, BuildContext context) {
    final clean = label.trim().toLowerCase();
    
    String? currentPath;
    try {
      currentPath = GoRouterState.of(context).uri.path;
    } catch (_) {}
    
    final isDoctorAssistant = currentPath?.startsWith('/workspace/') ?? false;
    
    if (isDoctorAssistant) {
      if (clean == 'students' || clean == 'الطلاب' || clean == 'إدارة الطلاب' || clean == 'وحدة إدارة الطلاب') {
        return '/workspace/students';
      }
      if (clean == 'staff' || clean == 'أعضاء هيئة التدريس' || clean == 'إدارة أعضاء هيئة التدريس' || clean == 'الموظفين' || clean == 'staff screen') {
        return '/workspace/staff';
      }
      if (clean == 'subjects' || clean == 'المواد' || clean == 'المقررات') {
        return '/workspace/subjects';
      }
      if (clean == 'quizzes' || clean == 'الاختبارات') {
        return '/workspace/quizzes';
      }
      if (clean == 'tasks' || clean == 'المهام') {
        return '/workspace/tasks';
      }
      if (clean == 'results' || clean == 'النتائج') {
        return '/workspace/results';
      }
      if (clean == 'schedule' || clean == 'الجدول' || clean == 'جدول المحاضرات' || clean == 'المواعيد') {
        return '/workspace/schedule';
      }
      if (clean == 'uploads' || clean == 'التحميلات' || clean == 'الملفات') {
        return '/workspace/uploads';
      }
      if (clean == 'settings' || clean == 'الإعدادات') {
        return '/workspace/settings';
      }
      if (clean == 'admin' || clean == 'إداري' || clean == 'dashboard' || clean == 'الرئيسية' || clean == 'لوحة التحكم' || clean == 'home' || clean == 'workspace') {
        return '/workspace/home';
      }
    } else {
      if (clean == 'students' || clean == 'الطلاب' || clean == 'إدارة الطلاب' || clean == 'وحدة إدارة الطلاب') {
        return RoutePaths.students;
      }
      if (clean == 'staff' || clean == 'أعضاء هيئة التدريس' || clean == 'إدارة أعضاء هيئة التدريس' || clean == 'الموظفين' || clean == 'staff screen') {
        return RoutePaths.staff;
      }
      if (clean == 'departments' || clean == 'الأقسام' || clean == 'أقسام') {
        return RoutePaths.departments;
      }
      if (clean == 'sections' || clean == 'الفصول' || clean == 'الشعب' || clean == 'الأقسام الأكاديمية') {
        return RoutePaths.sections;
      }
      if (clean == 'subjects' || clean == 'المواد' || clean == 'المقررات') {
        return RoutePaths.subjects;
      }
      if (clean == 'offerings' || clean == 'العروض' || clean == 'العروض الأكاديمية' || clean == 'course offerings') {
        return RoutePaths.courseOfferings;
      }
      if (clean == 'enrollments' || clean == 'التسجيلات' || clean == 'القبول') {
        return RoutePaths.enrollments;
      }
      if (clean == 'content' || clean == 'المحتوى' || clean == 'إدارة المحتوى') {
        return RoutePaths.content;
      }
      if (clean == 'schedule' || clean == 'الجدول' || clean == 'جدول المحاضرات' || clean == 'المواعيد') {
        return RoutePaths.schedule;
      }
      if (clean == 'uploads' || clean == 'التحميلات' || clean == 'الملفات') {
        return RoutePaths.uploads;
      }
      if (clean == 'notifications' || clean == 'الإشعارات') {
        return RoutePaths.notifications;
      }
      if (clean == 'moderation' || clean == 'الرقابة' || clean == 'الإشراف') {
        return RoutePaths.moderation;
      }
      if (clean == 'roles' || clean == 'الأدوار' || clean == 'الصلاحيات' || clean == 'roles & permissions') {
        return RoutePaths.roles;
      }
      if (clean == 'settings' || clean == 'الإعدادات') {
        return RoutePaths.settings;
      }
      if (clean == 'admin' || clean == 'إداري' || clean == 'dashboard' || clean == 'الرئيسية' || clean == 'لوحة التحكم') {
        return RoutePaths.dashboard;
      }
      if (clean == 'university' || clean == 'الجامعة') {
        return RoutePaths.dashboard;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact =
            AppBreakpoints.isMobile(context) || constraints.maxWidth < 1040;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (breadcrumbs.isNotEmpty)
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  for (var index = 0; index < breadcrumbs.length; index++) ...[
                    Builder(
                      builder: (context) {
                        final label = breadcrumbs[index];
                        final route = _getRoutePath(label, context);
                        final isClickable = route != null && index != breadcrumbs.length - 1;
                        
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: isClickable ? () => context.go(route) : null,
                            child: Ink(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                l10n.byValue(label),
                                style: textTheme.labelMedium?.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    if (index != breadcrumbs.length - 1)
                      Text('/', style: textTheme.labelMedium),
                  ],
                ],
              ),
            if (breadcrumbs.isNotEmpty) const SizedBox(height: AppSpacing.md),
            if (isCompact)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.byValue(title), style: textTheme.headlineMedium),
                  const SizedBox(height: AppSpacing.xs),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Text(
                      l10n.byValue(subtitle),
                      style: textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ),
                  if (actions.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: actions,
                    ),
                  ],
                ],
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.byValue(title),
                          style: textTheme.headlineMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 720),
                          child: Text(
                            l10n.byValue(subtitle),
                            style: textTheme.bodyMedium?.copyWith(
                              color: Theme.of(
                                context,
                              ).textTheme.bodySmall?.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (actions.isNotEmpty) ...[
                    const SizedBox(width: AppSpacing.md),
                    Flexible(
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          alignment: WrapAlignment.end,
                          children: actions,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
          ],
        );
      },
    );
  }
}
