import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import '../../../redux/app_state.dart';
import '../redux/announcements_actions.dart';
import '../data/announcement_model.dart';
import '../../../core/ui/widgets/state_view.dart';

class AnnouncementsScreen extends StatelessWidget {
  final int subjectId;
  const AnnouncementsScreen({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      onInit: (store) => store.dispatch(FetchAnnouncementsAction(subjectId)),
      converter: (store) => _ViewModel.fromStore(store, subjectId),
      builder: (context, vm) {
        return Scaffold(
          body: StateView(
            isLoading: vm.isLoading,
            isEmpty: vm.announcements.isEmpty,
            onRetry: () => vm.onRefresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: vm.announcements.length,
              itemBuilder: (context, index) {
                final announcement = vm.announcements[index];
                return _buildAnnouncementCard(context, announcement, vm);
              },
            ),
          ),
          floatingActionButton: vm.canManage ? FloatingActionButton(
            onPressed: () => _showCreateDialog(context, vm),
            child: const Icon(Icons.add),
          ) : null,
        );
      },
    );
  }

  Widget _buildAnnouncementCard(BuildContext context, Announcement announcement, _ViewModel vm) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: announcement.pinned ? 4 : 1,
      shape: announcement.pinned ? RoundedRectangleBorder(side: const BorderSide(color: Colors.blue, width: 2), borderRadius: BorderRadius.circular(12)) : null,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (announcement.pinned) const Icon(Icons.push_pin, size: 16, color: Colors.blue),
                if (announcement.pinned) const SizedBox(width: 8),
                Expanded(
                  child: Text(announcement.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                if (vm.canManage)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () => vm.onDelete(announcement.id),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(announcement.body),
            const SizedBox(height: 12),
            Text(
              announcement.createdAt.toLocal().toString().split('.')[0],
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateDialog(BuildContext context, _ViewModel vm) {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    bool pinned = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('New Announcement'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
              TextField(controller: bodyController, decoration: const InputDecoration(labelText: 'Body'), maxLines: 3),
              CheckboxListTile(
                title: const Text('Pin Announcement'),
                value: pinned,
                onChanged: (val) => setState(() => pinned = val!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                vm.onCreate(titleController.text, bodyController.text, pinned);
                Navigator.pop(context);
              },
              child: const Text('Post'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewModel {
  final List<Announcement> announcements;
  final bool isLoading;
  final bool canManage;
  final Function(String, String, bool) onCreate;
  final Function(int) onDelete;
  final VoidCallback onRefresh;

  _ViewModel({
    required this.announcements,
    required this.isLoading,
    required this.canManage,
    required this.onCreate,
    required this.onDelete,
    required this.onRefresh,
  });

  static _ViewModel fromStore(Store<AppState> store, int subjectId) {
    final role = store.state.authState.role;
    return _ViewModel(
      announcements: store.state.subjectsState.announcements[subjectId] ?? [],
      isLoading: store.state.subjectsState.isLoading,
      canManage: role == 'doctor' || role == 'assistant' || role == 'it',
      onCreate: (title, body, pinned) => store.dispatch(CreateAnnouncementAction(subjectId, title, body, pinned)),
      onDelete: (id) => store.dispatch(DeleteAnnouncementAction(subjectId, id)),
      onRefresh: () => store.dispatch(FetchAnnouncementsAction(subjectId)),
    );
  }
}
