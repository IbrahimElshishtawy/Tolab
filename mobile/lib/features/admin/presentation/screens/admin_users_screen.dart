import 'package:flutter/material.dart';
import '../../../../core/ui/widgets/university_widgets.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload),
            onPressed: () => _showImportBottomSheet(context),
            tooltip: 'Import Bulk',
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, index) {
          return UniversityCard(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text('User ${index + 1}'),
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
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Bulk Import Users', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),
            UniversityCard(
              padding: const EdgeInsets.all(32),
              onTap: () {},
              child: Column(
                children: [
                  const Icon(Icons.cloud_upload_outlined, size: 48, color: Colors.blue),
                  const SizedBox(height: 16),
                  const Text('Select CSV or Excel file'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppButton(text: 'Process File', onPressed: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}
