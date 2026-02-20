import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import '../../../redux/app_state.dart';
import '../data/models.dart';
import '../redux/tasks_actions.dart';
import '../../../core/ui/widgets/state_view.dart';

class SubmissionsListScreen extends StatelessWidget {
  final int taskId;
  final String taskTitle;

  const SubmissionsListScreen({super.key, required this.taskId, required this.taskTitle});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      onInit: (store) => store.dispatch(FetchSubmissionsAction(taskId)),
      converter: (store) => _ViewModel.fromStore(store, taskId),
      builder: (context, vm) {
        return Scaffold(
          appBar: AppBar(title: Text('Submissions: $taskTitle')),
          body: StateView(
            isLoading: vm.isLoading,
            error: vm.error,
            isEmpty: vm.submissions.isEmpty,
            onRetry: vm.onRefresh,
            child: ListView.builder(
              itemCount: vm.submissions.length,
              itemBuilder: (context, index) {
                final submission = vm.submissions[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(submission.studentName),
                  subtitle: Text('Submitted: ${submission.submittedAt.toLocal().toString().split('.')[0]}'),
                  trailing: Text(
                    submission.grade ?? 'Ungraded',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: submission.grade != null ? Colors.green : Colors.orange,
                    ),
                  ),
                  onTap: () => _showGradingDialog(context, submission),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showGradingDialog(BuildContext context, Submission submission) {
    final controller = TextEditingController(text: submission.grade ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Grade Submission: ${submission.studentName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (submission.fileUrl != null)
              ListTile(
                leading: const Icon(Icons.attach_file),
                title: const Text('View Attachment'),
                onTap: () {
                  // In a real app, open URL
                },
              ),
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Grade (e.g. A, 95, B+)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              StoreProvider.of<AppState>(context).dispatch(
                GradeSubmissionAction(taskId, submission.id, controller.text),
              );
              Navigator.pop(context);
            },
            child: const Text('Save Grade'),
          ),
        ],
      ),
    );
  }
}

class _ViewModel {
  final List<Submission> submissions;
  final bool isLoading;
  final String? error;
  final VoidCallback onRefresh;

  _ViewModel({
    required this.submissions,
    required this.isLoading,
    this.error,
    required this.onRefresh,
  });

  factory _ViewModel.fromStore(Store<AppState> store, int taskId) {
    return _ViewModel(
      submissions: store.state.tasksState.taskSubmissions[taskId] ?? [],
      isLoading: store.state.tasksState.isLoading,
      error: store.state.tasksState.error,
      onRefresh: () => store.dispatch(FetchSubmissionsAction(taskId)),
    );
  }
}
