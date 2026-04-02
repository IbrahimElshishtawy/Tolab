import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/navigation/navigation_items.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/state_views.dart';
import '../../../state/app_state.dart';
import '../../auth/state/session_selectors.dart';
import '../state/lectures_actions.dart';

class LecturesScreen extends StatelessWidget {
  const LecturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<DoctorAssistantAppState, _LecturesVm>(
      converter: (store) => _LecturesVm.fromStore(store),
      onInit: (store) => store.dispatch(LoadLecturesAction()),
      builder: (context, vm) {
        final user = vm.user;
        if (user == null) return const SizedBox.shrink();

        return AppShell(
          user: user,
          title: 'Lectures',
          activePath: AppRoutes.lectures,
          items: buildNavigationItems(user),
          trailing: user.hasPermission('lectures.create')
              ? AppButton(
                  label: 'New lecture',
                  icon: Icons.add_rounded,
                  onPressed: () => _showLectureSheet(context, vm.onSave),
                )
              : null,
          body: vm.items == null
              ? const LoadingStateView()
              : ListView.separated(
                  itemCount: vm.items!.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = vm.items![index];
                    return AppCard(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(item.title),
                        subtitle: Text('Week ${item.weekNumber} • ${item.instructorName}'),
                        trailing: AppBadge(
                          label: item.isPublished ? 'Published' : 'Draft',
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}

Future<void> _showLectureSheet(
  BuildContext context,
  void Function(Map<String, dynamic>) onSave,
) {
  final titleController = TextEditingController();
  final instructorController = TextEditingController();
  final weekController = TextEditingController(text: '1');

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(label: 'Title', controller: titleController),
            const SizedBox(height: 12),
            AppTextField(label: 'Instructor', controller: instructorController),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Week',
              controller: weekController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Save lecture',
              onPressed: () {
                onSave({
                  'title': titleController.text.trim(),
                  'instructor_name': instructorController.text.trim(),
                  'week_number': int.tryParse(weekController.text) ?? 1,
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );
}

class _LecturesVm {
  const _LecturesVm({
    required this.user,
    required this.items,
    required this.onSave,
  });

  final SessionUser? user;
  final List<LectureModel>? items;
  final void Function(Map<String, dynamic>) onSave;

  factory _LecturesVm.fromStore(Store<DoctorAssistantAppState> store) {
    return _LecturesVm(
      user: getCurrentUser(store.state),
      items: store.state.lecturesState.data,
      onSave: (payload) => store.dispatch(SaveLectureAction(payload)),
    );
  }
}
