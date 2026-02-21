import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import '../../../redux/app_state.dart';
import '../redux/reporting_actions.dart';
import '../data/reporting_models.dart';
import '../../../core/ui/widgets/state_view.dart';

class ProgressScreen extends StatelessWidget {
  final int subjectId;
  const ProgressScreen({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      onInit: (store) => store.dispatch(FetchProgressAction(subjectId)),
      converter: (store) => _ViewModel.fromStore(store, subjectId),
      builder: (context, vm) {
        final progress = vm.progress;
        if (progress == null && vm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (progress == null) {
          return const Center(child: Text('No progress data available.'));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSummaryCard(progress),
            const SizedBox(height: 24),
            const Text('Task Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...progress.submissions.map((sub) => _buildSubmissionItem(sub)),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(StudentProgress progress) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetric('Completion', '${(progress.completedTasks / progress.totalTasks * 100).toInt()}%'),
                _buildMetric('Avg Grade', '${progress.averageGrade.toStringAsFixed(1)}%'),
              ],
            ),
            const SizedBox(height: 20),
            LinearProgressIndicator(value: progress.completedTasks / progress.totalTasks),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildSubmissionItem(dynamic sub) {
    return Card(
      child: ListTile(
        title: Text('Task ID: ${sub['task_id']}'), // In real app, we'd have task title
        subtitle: Text('Submitted at: ${sub['submitted_at'].toString().split('T')[0]}'),
        trailing: Text(
          sub['grade'] != null ? '${sub['grade']}%' : 'Ungraded',
          style: TextStyle(fontWeight: FontWeight.bold, color: sub['grade'] != null ? Colors.green : Colors.orange),
        ),
      ),
    );
  }
}

class _ViewModel {
  final StudentProgress? progress;
  final bool isLoading;

  _ViewModel({this.progress, required this.isLoading});

  static _ViewModel fromStore(Store<AppState> store, int subjectId) {
    return _ViewModel(
      progress: store.state.subjectsState.studentProgress[subjectId],
      isLoading: store.state.subjectsState.isLoading,
    );
  }
}
