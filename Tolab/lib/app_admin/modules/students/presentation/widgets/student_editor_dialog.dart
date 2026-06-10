import 'dart:math';
import 'package:flutter/material.dart';

import '../../../../core/spacing/app_spacing.dart';
import '../../models/student_management_models.dart';

class StudentEditorDialog extends StatefulWidget {
  const StudentEditorDialog({super.key, required this.existing});

  final StudentProfile? existing;

  @override
  State<StudentEditorDialog> createState() => _StudentEditorDialogState();
}

class _StudentEditorDialogState extends State<StudentEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _studentIdController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _emergencyNameController;
  late final TextEditingController _emergencyPhoneController;
  late final TextEditingController _gpaController;
  late final TextEditingController _attendanceController;
  late final TextEditingController _notesController;
  late int _year;
  late String _department;
  late StudentEnrollmentStatus _status;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.fullName ?? '');
    _studentIdController = TextEditingController(
      text: existing?.studentNumber ?? '',
    );
    _emailController = TextEditingController(
      text: existing?.contact.email ?? '',
    );
    _phoneController = TextEditingController(
      text: existing?.contact.phone ?? '',
    );
    _addressController = TextEditingController(
      text: existing?.contact.address ?? '',
    );
    _emergencyNameController = TextEditingController(
      text: existing?.emergencyContact.name ?? '',
    );
    _emergencyPhoneController = TextEditingController(
      text: existing?.emergencyContact.phone ?? '',
    );
    _gpaController = TextEditingController(
      text: existing == null ? '0.00' : existing.gpa.toStringAsFixed(2),
    );
    _attendanceController = TextEditingController(
      text: existing == null ? '0' : existing.attendanceRate.toStringAsFixed(0),
    );
    _notesController = TextEditingController(text: existing?.notes ?? '');
    _year = existing?.year ?? 1;
    _department = existing?.department ?? 'Computer Science';
    _status = existing?.enrollmentStatus ?? StudentEnrollmentStatus.active;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _gpaController.dispose();
    _attendanceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'Add student' : 'Edit student'),
      content: SizedBox(
        width: 720,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                _dialogField(_nameController, 'Full name'),
                _dialogField(_studentIdController, 'Student ID'),
                _dialogField(
                  _emailController,
                  'Email',
                  validator: _emailValidator,
                ),
                _dialogField(_phoneController, 'Phone'),
                _dialogField(_addressController, 'Address'),
                _dialogField(_emergencyNameController, 'Emergency contact'),
                _dialogField(_emergencyPhoneController, 'Emergency phone'),
                _dialogField(_gpaController, 'GPA'),
                _dialogField(_attendanceController, 'Attendance %'),
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<int>(
                    initialValue: _year,
                    decoration: const InputDecoration(labelText: 'Year'),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Year 1')),
                      DropdownMenuItem(value: 2, child: Text('Year 2')),
                      DropdownMenuItem(value: 3, child: Text('Year 3')),
                      DropdownMenuItem(value: 4, child: Text('Year 4')),
                      DropdownMenuItem(value: 5, child: Text('Year 5')),
                    ],
                    onChanged: (value) =>
                        setState(() => _year = value ?? _year),
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<String>(
                    initialValue: _department,
                    decoration: const InputDecoration(labelText: 'Department'),
                    items: const [
                      DropdownMenuItem(
                        value: 'Computer Science',
                        child: Text('Computer Science'),
                      ),
                      DropdownMenuItem(
                        value: 'Information Systems',
                        child: Text('Information Systems'),
                      ),
                      DropdownMenuItem(
                        value: 'Engineering',
                        child: Text('Engineering'),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _department = value ?? _department),
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<StudentEnrollmentStatus>(
                    initialValue: _status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: [
                      for (final status in StudentEnrollmentStatus.values)
                        DropdownMenuItem(
                          value: status,
                          child: Text(status.label),
                        ),
                    ],
                    onChanged: (value) =>
                        setState(() => _status = value ?? _status),
                  ),
                ),
                TextFormField(
                  controller: _notesController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(labelText: 'Notes'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.of(context).pop(
              (widget.existing ??
                      StudentProfile(
                        id: '',
                        studentNumber: '',
                        fullName: '',
                        year: 1,
                        department: '',
                        className: '',
                        contact: const StudentContactInfo(
                          email: '',
                          phone: '',
                          address: '',
                        ),
                        emergencyContact: const StudentEmergencyContact(
                          name: '',
                          relationship: 'Guardian',
                          phone: '',
                        ),
                        enrollmentStatus: StudentEnrollmentStatus.active,
                        gpa: 0,
                        attendanceRate: 0,
                        averageGrade: 0,
                        registrationApproved: false,
                        courses: const [],
                        documents: const [],
                        activities: const [],
                        memberships: const [],
                        createdAt: DateTime.now(),
                        lastLoginAt: DateTime.now(),
                      ))
                  .copyWith(
                    studentNumber: _studentIdController.text.trim(),
                    fullName: _nameController.text.trim(),
                    year: _year,
                    department: _department,
                    className:
                        '${_department.split(' ').first.toUpperCase()}-${_year}A',
                    contact:
                        widget.existing?.contact.copyWith(
                          email: _emailController.text.trim(),
                          phone: _phoneController.text.trim(),
                          address: _addressController.text.trim(),
                        ) ??
                        StudentContactInfo(
                          email: _emailController.text.trim(),
                          phone: _phoneController.text.trim(),
                          address: _addressController.text.trim(),
                        ),
                    emergencyContact:
                        widget.existing?.emergencyContact.copyWith(
                          name: _emergencyNameController.text.trim(),
                          phone: _emergencyPhoneController.text.trim(),
                        ) ??
                        StudentEmergencyContact(
                          name: _emergencyNameController.text.trim(),
                          relationship: 'Guardian',
                          phone: _emergencyPhoneController.text.trim(),
                        ),
                    enrollmentStatus: _status,
                    gpa: double.parse(_gpaController.text.trim()),
                    attendanceRate: double.parse(
                      _attendanceController.text.trim(),
                    ),
                    averageGrade: max(
                      55,
                      double.parse(_gpaController.text.trim()) * 24,
                    ),
                    notes: _notesController.text.trim(),
                  ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _dialogField(
    TextEditingController controller,
    String label, {
    String? Function(String?)? validator,
  }) {
    return SizedBox(
      width: 220,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        validator:
            validator ??
            (value) =>
                (value == null || value.trim().isEmpty) ? 'Required' : null,
      ),
    );
  }

  String? _emailValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Required';
    if (!text.contains('@')) return 'Enter a valid email';
    return null;
  }
}
