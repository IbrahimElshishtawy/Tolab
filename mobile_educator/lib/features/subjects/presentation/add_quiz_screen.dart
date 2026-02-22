import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/validators/app_validators.dart';
import '../domain/subjects_models.dart';

class AddQuizScreen extends StatefulWidget {
  final int subjectId;
  const AddQuizScreen({super.key, required this.subjectId});

  @override
  State<AddQuizScreen> createState() => _AddQuizScreenState();
}

class _AddQuizScreenState extends State<AddQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _weekController = TextEditingController();
  final _authorController = TextEditingController();
  final _linkController = TextEditingController();
  QuizType _type = QuizType.offline;
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Quiz')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Quiz Name', border: OutlineInputBorder()),
                maxLength: 100,
                validator: (v) => AppValidators.validateMinMaxLength(v, 'Quiz Name', 2, 100),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<QuizType>(
                value: _type,
                items: QuizType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name.toUpperCase()))).toList(),
                onChanged: (v) => setState(() => _type = v!),
                decoration: const InputDecoration(labelText: 'Quiz Type', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              if (_type == QuizType.online)
                TextFormField(
                  controller: _linkController,
                  decoration: const InputDecoration(labelText: 'Quiz Link', border: OutlineInputBorder()),
                  validator: (v) => _type == QuizType.online ? AppValidators.validateRequired(v, 'Quiz Link') : null,
                ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(_selectedDate == null ? 'Select Date' : DateFormat('yyyy-MM-dd').format(_selectedDate!)),
                trailing: const Icon(Icons.calendar_month),
                onTap: () async {
                  final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                  if (date != null) setState(() => _selectedDate = date);
                },
                shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() && _selectedDate != null) {
                    // Save
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
                child: const Text('Save and Notify Students'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
