import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:admin_web/features/students/data/students_repository.dart';
import 'package:admin_web/features/academic/data/academic_repository.dart';

class StudentDetailScreen extends ConsumerStatefulWidget {
  final int? studentId;
  const StudentDetailScreen({super.key, this.studentId});

  @override
  ConsumerState<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends ConsumerState<StudentDetailScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _admissionTypeController = TextEditingController();
  final _admissionYearController = TextEditingController();

  String? _gender;
  DateTime? _dob;
  int? _departmentId;
  int? _academicYearId;
  String _status = 'Active';

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.studentId == null;
    if (widget.studentId != null) {
      _loadStudent();
    }
  }

  Future<void> _loadStudent() async {
    try {
      final student = await ref.read(studentsRepositoryProvider).getStudent(widget.studentId!);
      setState(() {
        _nameController.text = student.fullName;
        _emailController.text = student.email;
        _codeController.text = student.studentCode ?? '';
        _nationalIdController.text = student.nationalId ?? '';
        _nationalityController.text = student.nationality ?? '';
        _admissionTypeController.text = student.admissionType ?? '';
        _admissionYearController.text = student.yearOfAdmission?.toString() ?? '';
        _gender = student.gender;
        _dob = student.dob != null ? DateTime.parse(student.dob!) : null;
        _departmentId = student.departmentId;
        _academicYearId = student.academicYearId;
        _status = student.enrollmentStatus ?? 'Active';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading student: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final deptsAsync = ref.watch(departmentsProvider);
    final yearsAsync = ref.watch(academicYearsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.studentId == null ? 'Add New Student' : 'Student Profile'),
          bottom: widget.studentId == null
              ? null
              : const TabBar(
                  tabs: [
                    Tab(text: 'Information'),
                    Tab(text: 'Subject Enrollment'),
                  ],
                ),
          actions: [
            if (widget.studentId != null && !_isEditing)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => setState(() => _isEditing = true),
              ),
            if (_isEditing)
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: _saveForm,
              ),
          ],
        ),
        body: widget.studentId == null
            ? _buildInfoTab(deptsAsync, yearsAsync)
            : TabBarView(
                children: [
                  _buildInfoTab(deptsAsync, yearsAsync),
                  _buildSubjectsTab(),
                ],
              ),
      ),
    );
  }

  Widget _buildInfoTab(AsyncValue<List<Department>> deptsAsync, AsyncValue<List<AcademicYear>> yearsAsync) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Personal Information'),
                const SizedBox(height: 16),
                _buildPersonalFields(),
                const SizedBox(height: 32),
                _buildSectionTitle('Academic Information'),
                const SizedBox(height: 16),
                _buildAcademicFields(deptsAsync, yearsAsync),
                const SizedBox(height: 32),
                if (widget.studentId != null) _buildStatusActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectsTab() {
    if (widget.studentId == null) return const Center(child: Text('Save student information first.'));

    final subjectsAsync = ref.watch(subjectsProvider);
    final enrollmentsAsync = ref.watch(studentEnrollmentsProvider(widget.studentId!));

    return Column(
      children: [
        Expanded(
          child: subjectsAsync.when(
            data: (subjects) => enrollmentsAsync.when(
              data: (enrolledIds) => ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  final s = subjects[index];
                  final isEnrolled = enrolledIds.contains(s.id);
                  return CheckboxListTile(
                    title: Text(s.name),
                    subtitle: Text(s.code),
                    value: isEnrolled,
                    onChanged: (val) async {
                      final newIds = List<int>.from(enrolledIds);
                      if (val == true) {
                        newIds.add(s.id);
                      } else {
                        newIds.remove(s.id);
                      }
                      await ref.read(studentsRepositoryProvider).enrollStudent(widget.studentId!, newIds);
                      ref.invalidate(studentEnrollmentsProvider(widget.studentId!));
                    },
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error: $e')),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildPersonalFields() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 4,
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Full Name'),
          enabled: _isEditing,
          validator: (v) => v!.isEmpty ? 'Required' : null,
        ),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'University Email'),
          enabled: _isEditing,
          validator: (v) => v!.isEmpty ? 'Required' : null,
        ),
        TextFormField(
          controller: _codeController,
          decoration: const InputDecoration(labelText: 'Student Code'),
          enabled: _isEditing,
          validator: (v) => v!.isEmpty ? 'Required' : null,
        ),
        TextFormField(
          controller: _nationalIdController,
          decoration: const InputDecoration(labelText: 'National ID'),
          enabled: _isEditing,
        ),
        InkWell(
          onTap: _isEditing ? _selectDate : null,
          child: InputDecorator(
            decoration: const InputDecoration(labelText: 'Date of Birth'),
            child: Text(_dob == null ? '' : '${_dob!.day}/${_dob!.month}/${_dob!.year}'),
          ),
        ),
        TextFormField(
          controller: _nationalityController,
          decoration: const InputDecoration(labelText: 'Nationality'),
          enabled: _isEditing,
        ),
        DropdownButtonFormField<String>(
          value: _gender,
          decoration: const InputDecoration(labelText: 'Gender'),
          items: const [
            DropdownMenuItem(value: 'Male', child: Text('Male')),
            DropdownMenuItem(value: 'Female', child: Text('Female')),
          ],
          onChanged: _isEditing ? (v) => setState(() => _gender = v) : null,
        ),
      ],
    );
  }

  Widget _buildAcademicFields(AsyncValue<List<Department>> deptsAsync, AsyncValue<List<AcademicYear>> yearsAsync) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 4,
      children: [
        deptsAsync.when(
          data: (depts) => DropdownButtonFormField<int>(
            value: _departmentId,
            decoration: const InputDecoration(labelText: 'Department'),
            items: depts.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))).toList(),
            onChanged: _isEditing ? (v) => setState(() => _departmentId = v) : null,
            validator: (v) => v == null ? 'Required' : null,
          ),
          loading: () => const LinearProgressIndicator(),
          error: (_, __) => const Text('Error loading depts'),
        ),
        yearsAsync.when(
          data: (years) => DropdownButtonFormField<int>(
            value: _academicYearId,
            decoration: const InputDecoration(labelText: 'Academic Year'),
            items: years.map((y) => DropdownMenuItem(value: y.id, child: Text(y.name))).toList(),
            onChanged: _isEditing ? (v) => setState(() => _academicYearId = v) : null,
            validator: (v) => v == null ? 'Required' : null,
          ),
          loading: () => const LinearProgressIndicator(),
          error: (_, __) => const Text('Error loading years'),
        ),
        TextFormField(
          controller: _admissionYearController,
          decoration: const InputDecoration(labelText: 'Year of Admission'),
          enabled: _isEditing,
        ),
        TextFormField(
          controller: _admissionTypeController,
          decoration: const InputDecoration(labelText: 'Admission Type'),
          enabled: _isEditing,
        ),
      ],
    );
  }

  Widget _buildStatusActions() {
    return Card(
      color: _status == 'Suspended' ? Colors.red.shade50 : Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Enrollment Status: $_status', style: const TextStyle(fontWeight: FontWeight.bold)),
                if (_status == 'Suspended')
                  const Text('Student cannot login and stops receiving notifications.', style: TextStyle(fontSize: 12)),
              ],
            ),
            const Spacer(),
            if (_status == 'Active')
              ElevatedButton(
                onPressed: () => setState(() => _status = 'Suspended'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                child: const Text('Suspend Student'),
              )
            else
              ElevatedButton(
                onPressed: () => setState(() => _status = 'Active'),
                child: const Text('Activate Student'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'full_name': _nameController.text,
        'email': _emailController.text,
        'student_code': _codeController.text,
        'national_id': _nationalIdController.text,
        'nationality': _nationalityController.text,
        'admission_type': _admissionTypeController.text,
        'year_of_admission': int.tryParse(_admissionYearController.text),
        'gender': _gender,
        'dob': _dob?.toIso8601String().split('T')[0],
        'department_id': _departmentId,
        'academic_year_id': _academicYearId,
        'enrollment_status': _status,
      };

      try {
        if (widget.studentId == null) {
          data['password'] = 'default123'; // Default password for new students
          await ref.read(studentsRepositoryProvider).createStudent(data);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student created successfully')));
          context.go('/students');
        } else {
          await ref.read(studentsRepositoryProvider).updateStudent(widget.studentId!, data);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student updated successfully')));
          setState(() => _isEditing = false);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving student: $e')));
      }
    }
  }
}
