import 'package:flutter/material.dart';

import '../../../core/colors/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/values/app_spacing.dart';
import '../../../modules/shared/models/navigation_item.dart';
import '../widgets/admin_shell_frame.dart';

class ShellView extends StatelessWidget {
  const ShellView({
    super.key,
    required this.title,
    required this.currentItem,
    required this.child,
    this.actions = const [],
  });

  final String title;
  final NavigationItem currentItem;
  final Widget child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.pageGlow),
      child: AdminShellFrame(
        title: title,
        currentItem: currentItem,
        actions: actions,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(
              context.isMobile ? AppSpacing.md : AppSpacing.xl,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
