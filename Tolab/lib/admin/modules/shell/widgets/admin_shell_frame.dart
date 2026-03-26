import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_spacing.dart';
import '../../shared/models/navigation_item.dart';
import '../controllers/shell_controller.dart';

class AdminShellFrame extends GetView<ShellController> {
  const AdminShellFrame({
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
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 1024;

    return Scaffold(
      drawer: isDesktop ? null : _Sidebar(currentItem: currentItem),
      body: Row(
        children: [
          if (isDesktop) _Sidebar(currentItem: currentItem),
          Expanded(
            child: Column(
              children: [
                _TopBar(title: title, actions: actions),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, required this.actions});

  final String title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Row(
        children: [
          if (Scaffold.maybeOf(context)?.hasDrawer ?? false)
            Builder(
              builder: (context) => IconButton(
                onPressed: Scaffold.of(context).openDrawer,
                icon: const Icon(Icons.menu_rounded),
              ),
            ),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}

class _Sidebar extends GetView<ShellController> {
  const _Sidebar({required this.currentItem});

  final NavigationItem currentItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 268,
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tolab Admin', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: ListView.separated(
              itemCount: NavigationItem.values.length,
              separatorBuilder: (context, index) => const SizedBox(height: 4),
              itemBuilder: (_, index) {
                final item = NavigationItem.values[index];
                final selected = item == currentItem;
                return Material(
                  color: selected
                      ? Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => controller.goTo(item),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(item.icon, size: 18),
                          const SizedBox(width: 12),
                          Expanded(child: Text(item.label)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
