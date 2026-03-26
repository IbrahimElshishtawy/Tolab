import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/data/admin_data_table.dart';
import '../../../core/widgets/states/state_views.dart';
import '../../../data/models/admin_models.dart';
import '../controllers/management_controller.dart';

class ManagementPage<T extends AdminEntity> extends StatelessWidget {
  const ManagementPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.controller,
    required this.columns,
    this.onCreate,
    this.onTap,
    this.actionsBuilder,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final ManagementController<T> controller;
  final List<AdminTableColumn<T>> columns;
  final VoidCallback? onCreate;
  final ValueChanged<T>? onTap;
  final List<Widget> Function(T item)? actionsBuilder;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(subtitle),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                hintText: 'Search',
                prefixIcon: Icons.search_rounded,
                onChanged: controller.onSearchChanged,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            if (trailing != null) trailing!,
            if (onCreate != null) ...[
              const SizedBox(width: AppSpacing.md),
              AppButton(
                label: 'Add New',
                icon: Icons.add_rounded,
                onPressed: onCreate,
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const LoadingStateView();
            }
            final error = controller.errorMessage.value;
            if (error != null) {
              return ErrorStateView(message: error, onRetry: controller.load);
            }
            if (controller.items.isEmpty) {
              return EmptyStateView(
                title: 'Nothing here yet',
                subtitle: 'Add data or adjust your search filters.',
                actionLabel: onCreate == null ? null : 'Create record',
                onAction: onCreate,
              );
            }

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: AdminDataTable<T>(
                  items: controller.items,
                  columns: columns,
                  onTap: onTap,
                  actionsBuilder: actionsBuilder,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
