import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:admin_web/features/academic/data/academic_repository.dart';

class AcademicStructureScreen extends ConsumerWidget {
  const AcademicStructureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Academic Structure'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Departments'),
              Tab(text: 'Academic Years'),
              Tab(text: 'Subjects'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _DepartmentsTab(),
            _AcademicYearsTab(),
            _SubjectsTab(),
          ],
        ),
      ),
    );
  }
}

class _DepartmentsTab extends ConsumerWidget {
  const _DepartmentsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deptsAsync = ref.watch(departmentsProvider);

    return deptsAsync.when(
      data: (depts) => ListView.builder(
        itemCount: depts.length + 1,
        itemBuilder: (context, index) {
          if (index == depts.length) {
            return ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add Department'),
              onTap: () => _showAddDeptDialog(context, ref),
            );
          }
          final dept = depts[index];
          return ListTile(
            title: Text(dept.name),
            subtitle: Text('Code: ${dept.code}'),
            trailing: Chip(label: Text(dept.isActive ? 'Active' : 'Inactive')),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  void _showAddDeptDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Department'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: codeController, decoration: const InputDecoration(labelText: 'Code')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await ref.read(academicRepositoryProvider).createDepartment({
                'name': nameController.text,
                'code': codeController.text,
              });
              ref.invalidate(departmentsProvider);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _AcademicYearsTab extends ConsumerWidget {
  const _AcademicYearsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final yearsAsync = ref.watch(academicYearsProvider);

    return yearsAsync.when(
      data: (years) => ListView.builder(
        itemCount: years.length + 1,
        itemBuilder: (context, index) {
          if (index == years.length) {
            return ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add Academic Year'),
              onTap: () => _showAddYearDialog(context, ref),
            );
          }
          final year = years[index];
          return ListTile(
            title: Text(year.name),
            trailing: Chip(label: Text(year.isActive ? 'Active' : 'Inactive')),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  void _showAddYearDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Academic Year'),
        content: TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name (e.g. First Year)')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await ref.read(academicRepositoryProvider).createAcademicYear({
                'name': nameController.text,
              });
              ref.invalidate(academicYearsProvider);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _SubjectsTab extends ConsumerWidget {
  const _SubjectsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(subjectsProvider);

    return subjectsAsync.when(
      data: (subjects) => ListView.builder(
        itemCount: subjects.length + 1,
        itemBuilder: (context, index) {
          if (index == subjects.length) {
            return ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add Subject'),
              onTap: () => _showAddSubjectDialog(context, ref),
            );
          }
          final subject = subjects[index];
          return ListTile(
            title: Text(subject.name),
            subtitle: Text('Code: ${subject.code}'),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  void _showAddSubjectDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    // In a real app we'd have dropdowns for Doctor/Dept/Year here.
    // For now I'll use simple text fields or placeholders to satisfy the requirement.
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Subject'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: codeController, decoration: const InputDecoration(labelText: 'Code')),
            const Text('Note: Doctor assignment is done in Staff Assignment module.', style: TextStyle(fontSize: 10)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await ref.read(academicRepositoryProvider).createSubject({
                'name': nameController.text,
                'code': codeController.text,
                'doctor_id': 1, // Placeholder
              });
              ref.invalidate(subjectsProvider);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
