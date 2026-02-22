import 'package:flutter/material.dart';
import '../../../core/validators/app_validators.dart';

class AddTaskScreen extends StatefulWidget {
  final int subjectId;
  const AddTaskScreen({super.key, required this.subjectId});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weekController = TextEditingController();
  final _refNameController = TextEditingController();
  final _authorController = TextEditingController();
  String? _filePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Task')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _weekController,
                decoration: const InputDecoration(labelText: 'Week Number', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                maxLength: 2,
                validator: (v) => AppValidators.validateRequired(v, 'Week Number'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _refNameController,
                decoration: const InputDecoration(labelText: 'Lecture/Section Name', border: OutlineInputBorder()),
                maxLength: 100,
                validator: (v) => AppValidators.validateMinMaxLength(v, 'Name', 2, 100),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(labelText: 'Author Name', border: OutlineInputBorder()),
                maxLength: 100,
                validator: (v) => AppValidators.validateMinMaxLength(v, 'Author Name', 2, 100),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => setState(() => _filePath = 'task_manual.pdf'), // Mock file picking
                icon: const Icon(Icons.upload_file),
                label: Text(_filePath ?? 'Upload PDF Content'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() && _filePath != null) {
                    // Save
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                child: const Text('Save and Notify Students'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
