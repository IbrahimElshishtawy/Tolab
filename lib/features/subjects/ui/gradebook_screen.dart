import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import '../../../redux/app_state.dart';
import '../redux/reporting_actions.dart';
import '../data/reporting_models.dart';
import '../../../core/ui/widgets/state_view.dart';

class GradebookScreen extends StatelessWidget {
  final int subjectId;
  const GradebookScreen({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      onInit: (store) => store.dispatch(FetchGradebookAction(subjectId)),
      converter: (store) => _ViewModel.fromStore(store, subjectId),
      builder: (context, vm) {
        return Scaffold(
          body: StateView(
            isLoading: vm.isLoading,
            isEmpty: vm.gradebook.isEmpty,
            onRetry: () => vm.onRefresh(),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Student Name')),
                  DataColumn(label: Text('Task 1')),
                  DataColumn(label: Text('Task 2')),
                  DataColumn(label: Text('Total')),
                ],
                rows: vm.gradebook.map((entry) {
                  return DataRow(cells: [
                    DataCell(Text(entry.studentName)),
                    DataCell(Text(entry.tasks.isNotEmpty ? (entry.tasks[0]['grade']?.toString() ?? 'N/A') : 'N/A')),
                    DataCell(Text(entry.tasks.length > 1 ? (entry.tasks[1]['grade']?.toString() ?? 'N/A') : 'N/A')),
                    DataCell(const Text('-')),
                  ]);
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ViewModel {
  final List<GradebookEntry> gradebook;
  final bool isLoading;
  final VoidCallback onRefresh;

  _ViewModel({required this.gradebook, required this.isLoading, required this.onRefresh});

  static _ViewModel fromStore(Store<AppState> store, int subjectId) {
    return _ViewModel(
      gradebook: (store.state.subjectsState.gradebooks[subjectId] ?? []).cast<GradebookEntry>(),
      isLoading: store.state.subjectsState.isLoading,
      onRefresh: () => store.dispatch(FetchGradebookAction(subjectId)),
    );
  }
}
