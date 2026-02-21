import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import '../../../redux/app_state.dart';
import '../redux/attendance_actions.dart';
import '../data/attendance_model.dart';
import '../../../core/ui/widgets/state_view.dart';

class AttendanceScreen extends StatelessWidget {
  final int subjectId;
  const AttendanceScreen({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      onInit: (store) => store.dispatch(FetchAttendanceAction(subjectId)),
      converter: (store) => _ViewModel.fromStore(store, subjectId),
      builder: (context, vm) {
        return Scaffold(
          body: StateView(
            isLoading: vm.isLoading,
            isEmpty: vm.attendanceData.isEmpty,
            onRetry: () => vm.onRefresh(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (!vm.isEducator) _buildStudentCheckIn(context, vm),
                if (vm.isEducator) _buildEducatorActions(context, vm),
                const SizedBox(height: 24),
                const Text('Attendance History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...vm.attendanceData.map((item) => _buildHistoryItem(item, vm.isEducator)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStudentCheckIn(BuildContext context, _ViewModel vm) {
    final codeController = TextEditingController();
    return Card(
      color: Colors.blue.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Enter Attendance Code', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(hintText: 'e.g. AB1234', border: OutlineInputBorder()),
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // In a real app we'd need to find the active session first
                // For this mock, we assume session ID 1
                vm.onCheckIn(1, codeController.text);
              },
              child: const Text('Check In'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEducatorActions(BuildContext context, _ViewModel vm) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => vm.onStartSession('Lecture', 15),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Lecture'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => vm.onStartSession('Section', 15),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Section'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(dynamic item, bool isEducator) {
    if (isEducator) {
      final session = item as AttendanceSession;
      return Card(
        child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.people)),
          title: Text('${session.type} Session'),
          subtitle: Text('Code: ${session.code} | Starts: ${session.startsAt.toLocal().toString().split('.')[0]}'),
          trailing: const Icon(Icons.chevron_right),
        ),
      );
    } else {
      final record = item as AttendanceRecord;
      return Card(
        child: ListTile(
          leading: const Icon(Icons.check_circle, color: Colors.green),
          title: const Text('Present'),
          subtitle: Text('Checked in at: ${record.checkedInAt.toLocal().toString().split('.')[0]}'),
        ),
      );
    }
  }
}

class _ViewModel {
  final List<dynamic> attendanceData;
  final bool isLoading;
  final bool isEducator;
  final Function(String, int) onStartSession;
  final Function(int, String) onCheckIn;
  final VoidCallback onRefresh;

  _ViewModel({
    required this.attendanceData,
    required this.isLoading,
    required this.isEducator,
    required this.onStartSession,
    required this.onCheckIn,
    required this.onRefresh,
  });

  static _ViewModel fromStore(Store<AppState> store, int subjectId) {
    final role = store.state.authState.role;
    return _ViewModel(
      attendanceData: store.state.subjectsState.attendance[subjectId] ?? [],
      isLoading: store.state.subjectsState.isLoading,
      isEducator: role != 'student',
      onStartSession: (type, duration) => store.dispatch(StartAttendanceSessionAction(subjectId, type, duration)),
      onCheckIn: (sessionId, code) => store.dispatch(CheckInAction(sessionId, code)),
      onRefresh: () => store.dispatch(FetchAttendanceAction(subjectId)),
    );
  }
}
