import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:admin_web/features/academic/data/academic_repository.dart';
import 'package:admin_web/core/network/api_client.dart';

class ScheduleEntry {
  final int id;
  final int subjectId;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final String location;
  final String type;

  ScheduleEntry({
    required this.id,
    required this.subjectId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.type,
  });

  factory ScheduleEntry.fromJson(Map<String, dynamic> json) => ScheduleEntry(
        id: json['id'],
        subjectId: json['subject_id'],
        dayOfWeek: json['day_of_week'],
        startTime: json['start_time'],
        endTime: json['end_time'],
        location: json['location'],
        type: json['type'],
      );
}

class ScheduleRepository {
  final Ref _ref;
  ScheduleRepository(this._ref);

  Future<List<ScheduleEntry>> getSchedule() async {
    final response = await _ref.read(apiClientProvider).get('/admin/schedule');
    return (response.data as List).map((e) => ScheduleEntry.fromJson(e)).toList();
  }

  Future<void> createSchedule(Map<String, dynamic> data) async {
    await _ref.read(apiClientProvider).post('/admin/schedule', data: data);
  }
}

final scheduleRepositoryProvider = Provider((ref) => ScheduleRepository(ref));
final scheduleProvider = FutureProvider((ref) => ref.watch(scheduleRepositoryProvider).getSchedule());

class ScheduleManagementScreen extends ConsumerStatefulWidget {
  const ScheduleManagementScreen({super.key});

  @override
  ConsumerState<ScheduleManagementScreen> createState() => _ScheduleManagementScreenState();
}

class _ScheduleManagementScreenState extends ConsumerState<ScheduleManagementScreen> {
  int? _departmentId;
  int? _academicYearId;

  @override
  Widget build(BuildContext context) {
    final deptsAsync = ref.watch(departmentsProvider);
    final yearsAsync = ref.watch(academicYearsProvider);
    final scheduleAsync = ref.watch(scheduleProvider);
    final subjectsAsync = ref.watch(subjectsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Class Schedule')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildFilters(deptsAsync, yearsAsync),
            const SizedBox(height: 16),
            if (_departmentId != null && _academicYearId != null)
              Expanded(
                child: scheduleAsync.when(
                  data: (entries) => _buildScheduleTable(entries, subjectsAsync),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Error: $e')),
                ),
              )
            else
              const Expanded(child: Center(child: Text('Please select Department and Academic Year to view schedule'))),
          ],
        ),
      ),
      floatingActionButton: (_departmentId != null && _academicYearId != null)
          ? FloatingActionButton(
              onPressed: () => _showAddEntryDialog(context, ref, subjectsAsync),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildFilters(AsyncValue<List<Department>> deptsAsync, AsyncValue<List<AcademicYear>> yearsAsync) {
    return Row(
      children: [
        Expanded(
          child: deptsAsync.when(
            data: (depts) => DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Department'),
              value: _departmentId,
              items: depts.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))).toList(),
              onChanged: (val) => setState(() => _departmentId = val),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const Text('Error'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: yearsAsync.when(
            data: (years) => DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Academic Year'),
              value: _academicYearId,
              items: years.map((y) => DropdownMenuItem(value: y.id, child: Text(y.name))).toList(),
              onChanged: (val) => setState(() => _academicYearId = val),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const Text('Error'),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleTable(List<ScheduleEntry> entries, AsyncValue<List<Subject>> subjectsAsync) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    return subjectsAsync.when(
      data: (subjects) {
        return ListView(
          children: [
            DataTable(
              columns: const [
                DataColumn(label: Text('Day')),
                DataColumn(label: Text('Time')),
                DataColumn(label: Text('Subject')),
                DataColumn(label: Text('Room')),
                DataColumn(label: Text('Type')),
              ],
              rows: entries.map((e) {
                final subject = subjects.firstWhere((s) => s.id == e.subjectId, orElse: () => Subject(id: 0, name: 'Unknown', code: ''));
                return DataRow(cells: [
                  DataCell(Text(days[e.dayOfWeek])),
                  DataCell(Text('${e.startTime} - ${e.endTime}')),
                  DataCell(Text(subject.name)),
                  DataCell(Text(e.location)),
                  DataCell(Text(e.type)),
                ]);
              }).toList(),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Text('Error loading subjects: $e'),
    );
  }

  void _showAddEntryDialog(BuildContext context, WidgetRef ref, AsyncValue<List<Subject>> subjectsAsync) {
    int? selectedSubjectId;
    int selectedDay = 0;
    final startTimeController = TextEditingController(text: '08:00');
    final endTimeController = TextEditingController(text: '10:00');
    final roomController = TextEditingController();
    String selectedType = 'Lecture';

    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Schedule Entry'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                subjectsAsync.when(
                  data: (subjects) => DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: 'Subject'),
                    value: selectedSubjectId,
                    items: subjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                    onChanged: (val) => setState(() => selectedSubjectId = val),
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (e, s) => Text('Error: $e'),
                ),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Day'),
                  value: selectedDay,
                  items: List.generate(7, (i) => DropdownMenuItem(value: i, child: Text(days[i]))),
                  onChanged: (val) => setState(() => selectedDay = val!),
                ),
                TextField(controller: startTimeController, decoration: const InputDecoration(labelText: 'Start Time (HH:MM)')),
                TextField(controller: endTimeController, decoration: const InputDecoration(labelText: 'End Time (HH:MM)')),
                TextField(controller: roomController, decoration: const InputDecoration(labelText: 'Room')),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Type'),
                  value: selectedType,
                  items: const [
                    DropdownMenuItem(value: 'Lecture', child: Text('Lecture')),
                    DropdownMenuItem(value: 'Section', child: Text('Section')),
                  ],
                  onChanged: (val) => setState(() => selectedType = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: selectedSubjectId == null
                  ? null
                  : () async {
                      await ref.read(scheduleRepositoryProvider).createSchedule({
                        'subject_id': selectedSubjectId,
                        'day_of_week': selectedDay,
                        'start_time': startTimeController.text,
                        'end_time': endTimeController.text,
                        'location': roomController.text,
                        'type': selectedType,
                      });
                      ref.invalidate(scheduleProvider);
                      Navigator.pop(context);
                    },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
