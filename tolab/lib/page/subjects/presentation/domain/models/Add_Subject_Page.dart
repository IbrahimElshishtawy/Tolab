// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tolab/models/subject_model.dart';
import 'package:tolab/page/subjects/presentation/domain/models/subject_view_model.dart';

class AddSubjectPage extends StatefulWidget {
  const AddSubjectPage({super.key});

  @override
  State<AddSubjectPage> createState() => _AddSubjectPageState();
}

class _AddSubjectPageState extends State<AddSubjectPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  double _progress = 0.0;
  bool _isLoading = false;

  Future<void> _addSubject() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final id = DateTime.now().millisecondsSinceEpoch.toString();

        SubjectModel newSubject = SubjectModel(
          id: id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          progress: _progress,
        );

        await Provider.of<SubjectViewModel>(
          context,
          listen: false,
        ).addSubject(newSubject);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم إضافة المادة بنجاح ✅")),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("خطأ أثناء الإضافة: $e")));
      }

      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("إضافة مادة جديدة"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "اسم المادة",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "أدخل اسم المادة" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "وصف المادة",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "أدخل وصف المادة" : null,
              ),
              const SizedBox(height: 16),
              Text("نسبة التقدم: ${(_progress * 100).toStringAsFixed(0)}%"),
              Slider(
                value: _progress,
                onChanged: (value) {
                  setState(() {
                    _progress = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _addSubject,
                      icon: const Icon(Icons.add),
                      label: const Text("إضافة المادة"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
