import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:admin_web/features/academic/data/academic_repository.dart';
import 'package:admin_web/features/students/data/students_repository.dart';

class StaffAssignmentScreen extends ConsumerWidget {
  const StaffAssignmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(subjectsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Staff Assignment')),
      body: subjectsAsync.when(
        data: (subjects) => ListView.builder(
          itemCount: subjects.length,
          itemBuilder: (context, index) {
            final s = subjects[index];
            return ListTile(
              title: Text(s.name),
              subtitle: Text('Code: ${s.code}'),
              trailing: ElevatedButton(
                onPressed: () => _showAssignDialog(context, ref, s),
                child: const Text('Assign Staff'),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _showAssignDialog(BuildContext context, WidgetRef ref, Subject subject) {
    final staffAsync = ref.watch(staffProvider);
    int? selectedStaffId;
    String selectedRole = 'doctor';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Assign Staff to ${subject.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              staffAsync.when(
                data: (staff) => DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Staff Member'),
                  value: selectedStaffId,
                  items: staff.map((s) => DropdownMenuItem(value: s.id, child: Text('${s.fullName} (${s.role})'))).toList(),
                  onChanged: (val) => setState(() => selectedStaffId = val),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, s) => Text('Error: $e'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Role'),
                value: selectedRole,
                items: const [
                  DropdownMenuItem(value: 'doctor', child: Text('Doctor')),
                  DropdownMenuItem(value: 'assistant', child: Text('Assistant')),
                ],
                onChanged: (val) => setState(() => selectedRole = val!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: selectedStaffId == null
                  ? null
                  : () async {
                      await ref.read(studentsRepositoryProvider).assignStaff(subject.id, selectedStaffId!, selectedRole);
                      ref.invalidate(subjectsProvider);
                      Navigator.pop(context);
                    },
              child: const Text('Assign'),
            ),
          ],
        ),
      ),
    );
  }
}
