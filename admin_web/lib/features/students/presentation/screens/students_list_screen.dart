import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:admin_web/features/students/data/students_repository.dart';
import 'package:admin_web/features/academic/data/academic_repository.dart';

class StudentsListScreen extends ConsumerStatefulWidget {
  const StudentsListScreen({super.key});

  @override
  ConsumerState<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends ConsumerState<StudentsListScreen> {
  int _page = 1;
  String? _search;
  int? _departmentId;
  int? _academicYearId;
  String? _status;

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(studentsListProvider({
      'page': _page,
      'search': _search,
      'departmentId': _departmentId,
      'academicYearId': _academicYearId,
      'status': _status,
    }));

    final deptsAsync = ref.watch(departmentsProvider);
    final yearsAsync = ref.watch(academicYearsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              context.go('/students/new');
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Student'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildFilters(deptsAsync, yearsAsync),
            const SizedBox(height: 16),
            Expanded(
              child: studentsAsync.when(
                data: (data) => _buildTable(data['items'] as List<User>, data['total'] as int),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(AsyncValue<List<Department>> deptsAsync, AsyncValue<List<AcademicYear>> yearsAsync) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Search by Name, Code or Email',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (val) => setState(() {
                  _search = val.isEmpty ? null : val;
                  _page = 1;
                }),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: deptsAsync.when(
                data: (depts) => DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Department'),
                  value: _departmentId,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Departments')),
                    ...depts.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))),
                  ],
                  onChanged: (val) => setState(() {
                    _departmentId = val;
                    _page = 1;
                  }),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Error loading depts'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: yearsAsync.when(
                data: (years) => DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Academic Year'),
                  value: _academicYearId,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Years')),
                    ...years.map((y) => DropdownMenuItem(value: y.id, child: Text(y.name))),
                  ],
                  onChanged: (val) => setState(() {
                    _academicYearId = val;
                    _page = 1;
                  }),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Error loading years'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Status'),
                value: _status,
                items: const [
                  DropdownMenuItem(value: null, child: Text('All Statuses')),
                  DropdownMenuItem(value: 'Active', child: Text('Active')),
                  DropdownMenuItem(value: 'Suspended', child: Text('Suspended')),
                  DropdownMenuItem(value: 'Graduated', child: Text('Graduated')),
                ],
                onChanged: (val) => setState(() {
                  _status = val;
                  _page = 1;
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTable(List<User> students, int total) {
    if (students.isEmpty) {
      return const Center(child: Text('No students found.'));
    }

    return DataTable2(
      columnSpacing: 12,
      horizontalMargin: 12,
      minWidth: 800,
      columns: const [
        DataColumn2(label: Text('Name'), size: ColumnSize.L),
        DataColumn(label: Text('Code')),
        DataColumn(label: Text('Email')),
        DataColumn(label: Text('Status')),
        DataColumn(label: Text('Actions')),
      ],
      rows: students.map((student) {
        return DataRow(cells: [
          DataCell(Text(student.fullName)),
          DataCell(Text(student.studentCode ?? '-')),
          DataCell(Text(student.email)),
          DataCell(Chip(
            label: Text(student.enrollmentStatus ?? 'Active'),
            backgroundColor: student.enrollmentStatus == 'Suspended' ? Colors.red.shade100 : Colors.green.shade100,
          )),
          DataCell(Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                   context.go('/students/${student.id}');
                },
              ),
              IconButton(
                icon: const Icon(Icons.remove_red_eye),
                onPressed: () {
                   context.go('/students/${student.id}');
                },
              ),
            ],
          )),
        ]);
      }).toList(),
    );
  }
}
