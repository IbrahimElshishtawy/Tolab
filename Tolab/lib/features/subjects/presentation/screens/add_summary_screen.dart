import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';
import '../../../../redux/app_state.dart';
import '../../redux/subjects_actions.dart';
import '../../data/models.dart';
import '../../../../core/localization/localization_manager.dart';

class AddSummaryScreen extends StatefulWidget {
  final int subjectId;
  const AddSummaryScreen({super.key, required this.subjectId});

  @override
  State<AddSummaryScreen> createState() => _AddSummaryScreenState();
}

class _AddSummaryScreenState extends State<AddSummaryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _studentNameController = TextEditingController();
  final _videoUrlController = TextEditingController();
  String? _selectedFileName;

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) return '$fieldName is required';
    if (value.length < 2) return '$fieldName is too short';
    return null;
  }

  String? _validateYouTube(String? value) {
    if (value == null || value.isEmpty) return null;
    final ytRegex = RegExp(r'^(https?://)?(www\.)?(youtube\.com|youtu\.be)/.+$');
    if (!ytRegex.hasMatch(value)) return 'Invalid YouTube link';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('add_summary'.tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                maxLength: 100,
                decoration: InputDecoration(
                  labelText: 'Summary Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  counterText: "",
                ),
                validator: (v) => _validateRequired(v, 'Summary name'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _studentNameController,
                maxLength: 100,
                decoration: InputDecoration(
                  labelText: 'Student Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  counterText: "",
                ),
                validator: (v) => _validateRequired(v, 'Student name'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _videoUrlController,
                decoration: InputDecoration(
                  labelText: 'Video Link (Optional)',
                  hintText: 'https://youtube.com/...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: _validateYouTube,
              ),
              const SizedBox(height: 24),
              InkWell(
                onTap: () {
                  setState(() => _selectedFileName = 'summary_draft.pdf');
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.upload_file, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedFileName ?? 'Upload PDF/Image (Optional)',
                          style: TextStyle(color: _selectedFileName == null ? Colors.grey : Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    final summary = Summary(
                      id: DateTime.now().millisecondsSinceEpoch,
                      name: _nameController.text,
                      studentName: _studentNameController.text,
                      content: 'Student shared summary',
                      videoUrl: _videoUrlController.text.isNotEmpty ? _videoUrlController.text : null,
                      pdfUrl: _selectedFileName != null ? 'https://example.com/draft.pdf' : null,
                    );

                    StoreProvider.of<AppState>(context).dispatch(AddSummaryAction(widget.subjectId, summary));

                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Summary added successfully')));
                    context.pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
