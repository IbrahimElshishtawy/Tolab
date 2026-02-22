import 'package:flutter/material.dart';
import '../../../core/validators/app_validators.dart';

class AddLectureScreen extends StatefulWidget {
  final int subjectId;
  const AddLectureScreen({super.key, required this.subjectId});

  @override
  State<AddLectureScreen> createState() => _AddLectureScreenState();
}

class _AddLectureScreenState extends State<AddLectureScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _weekController = TextEditingController();
  final _doctorController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Lecture')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Lecture Name', border: OutlineInputBorder()),
                maxLength: 100,
                validator: (v) => AppValidators.validateMinMaxLength(v, 'Lecture Name', 2, 100),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _weekController,
                decoration: const InputDecoration(labelText: 'Week Number', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                maxLength: 2,
                validator: (v) => AppValidators.validateRequired(v, 'Week Number'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _doctorController,
                decoration: const InputDecoration(labelText: 'Doctor Name', border: OutlineInputBorder()),
                maxLength: 100,
                validator: (v) => AppValidators.validateMinMaxLength(v, 'Doctor Name', 2, 100),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {}, // File picker
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload PDF/Image'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
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
