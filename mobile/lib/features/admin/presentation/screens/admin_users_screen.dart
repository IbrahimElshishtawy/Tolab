import 'package:flutter/material.dart';
import '../../../../core/ui/widgets/university_widgets.dart';
import '../../../../core/ui/widgets/app_scaffold.dart';
import '../../../../core/ui/tokens/spacing_tokens.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'User Management',
      actions: [
        IconButton(
          icon: const Icon(Icons.file_upload),
          onPressed: () => _showImportBottomSheet(context),
          tooltip: 'Import Bulk',
        ),
      ],
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.l),
        itemCount: 10,
        itemBuilder: (context, index) {
          return AppCard(
            margin: const EdgeInsets.only(bottom: AppSpacing.m),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text('User ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('student${index + 1}@university.edu'),
              trailing: Switch(value: true, onChanged: (v) {}),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.person_add),
      ),
    );
  }

  void _showImportBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Bulk Import Users', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.xxl),
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.xxxl),
              onTap: () {},
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              child: Column(
                children: [
                  Icon(Icons.cloud_upload_outlined, size: 48, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: AppSpacing.l),
                  const Text('Select CSV or Excel file'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppButton(text: 'Process File', onPressed: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}
