import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../../../redux/app_state.dart';
import '../data/models.dart';
import '../redux/tasks_actions.dart';

class TaskFormScreen extends StatefulWidget {
  final int subjectId;
  final Task? task; // null if creating, not null if editing

  const TaskFormScreen({super.key, required this.subjectId, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _dueDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
    _dueDate = widget.task?.dueDate ?? DateTime.now().add(const Duration(days: 7));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Create Task' : 'Edit Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Due Date'),
                subtitle: Text(_dueDate.toLocal().toString().split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _dueDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() => _dueDate = picked);
                  }
                },
              ),
              const Spacer(),
              StoreConnector<AppState, bool>(
                converter: (store) => store.state.tasksState.isOperating,
                builder: (context, isOperating) {
                  return ElevatedButton(
                    onPressed: isOperating ? null : _submit,
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                    child: isOperating
                        ? const CircularProgressIndicator()
                        : Text(widget.task == null ? 'Create Task' : 'Save Changes'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final store = StoreProvider.of<AppState>(context);
      final task = Task(
        id: widget.task?.id ?? 0,
        title: _titleController.text,
        description: _descriptionController.text,
        dueDate: _dueDate,
      );

      if (widget.task == null) {
        store.dispatch(CreateTaskAction(widget.subjectId, task));
      } else {
        store.dispatch(UpdateTaskAction(task));
      }

      // Navigate back after success - in a real app we'd use a listener for success action
      // For this mock-driven approach, we just pop.
      Navigator.pop(context);
    }
  }
}
