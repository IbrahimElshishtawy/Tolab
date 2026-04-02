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
import '../state/quizzes_actions.dart';

class QuizzesScreen extends StatelessWidget {
  const QuizzesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<DoctorAssistantAppState, _QuizzesVm>(
      converter: (store) => _QuizzesVm.fromStore(store),
      onInit: (store) => store.dispatch(LoadQuizzesAction()),
      builder: (context, vm) {
        final user = vm.user;
        if (user == null) return const SizedBox.shrink();

        return AppShell(
          user: user,
          title: 'Quizzes',
          activePath: AppRoutes.quizzes,
          items: buildNavigationItems(user),
          trailing: user.hasPermission('quizzes.create')
              ? AppButton(
                  label: 'New quiz',
                  icon: Icons.add_rounded,
                  onPressed: () => _showQuizSheet(context, vm.onSave),
                )
              : null,
          body: vm.items == null
              ? const LoadingStateView()
              : ListView(
                  children: vm.items!
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AppCard(
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(item.title),
                              subtitle: Text('${item.ownerName} • ${item.quizDate}'),
                              trailing: AppBadge(label: item.quizType),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
        );
      },
    );
  }
}

Future<void> _showQuizSheet(
  BuildContext context,
  void Function(Map<String, dynamic>) onSave,
) {
  final titleController = TextEditingController();
  final dateController = TextEditingController();

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
            AppTextField(label: 'Quiz title', controller: titleController),
            const SizedBox(height: 12),
            AppTextField(label: 'Quiz date', controller: dateController),
            const SizedBox(height: 12),
            AppButton(
              label: 'Save quiz',
              onPressed: () {
                onSave({
                  'title': titleController.text.trim(),
                  'quiz_date': dateController.text.trim(),
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

class _QuizzesVm {
  const _QuizzesVm({
    required this.user,
    required this.items,
    required this.onSave,
  });

  final SessionUser? user;
  final List<QuizModel>? items;
  final void Function(Map<String, dynamic>) onSave;

  factory _QuizzesVm.fromStore(Store<DoctorAssistantAppState> store) {
    return _QuizzesVm(
      user: getCurrentUser(store.state),
      items: store.state.quizzesState.data,
      onSave: (payload) => store.dispatch(SaveQuizAction(payload)),
    );
  }
}
