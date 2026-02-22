import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/validators/app_validators.dart';
import '../../auth/presentation/auth_providers.dart';

class AddSectionScreen extends ConsumerStatefulWidget {
  final int subjectId;
  const AddSectionScreen({super.key, required this.subjectId});

  @override
  State<AddSectionScreen> createState() => _AddSectionScreenState();
}

class _AddSectionScreenState extends ConsumerState<AddSectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _weekController = TextEditingController();
  final _assistantController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(userRoleProvider);
    if (role != 'assistant') {
      return Scaffold(
        appBar: AppBar(title: const Text('Add Section')),
        body: const Center(child: Text('Only assistants can add sections')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Add Section')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Section Name', border: OutlineInputBorder()),
                maxLength: 100,
                validator: (v) => AppValidators.validateMinMaxLength(v, 'Section Name', 2, 100),
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
                controller: _assistantController,
                decoration: const InputDecoration(labelText: 'Assistant Name', border: OutlineInputBorder()),
                maxLength: 100,
                validator: (v) => AppValidators.validateMinMaxLength(v, 'Assistant Name', 2, 100),
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
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                child: const Text('Save and Notify Students'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
