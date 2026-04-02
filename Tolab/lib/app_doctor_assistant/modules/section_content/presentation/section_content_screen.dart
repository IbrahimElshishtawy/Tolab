import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../../../core/models/content_models.dart';
import '../../../core/models/session_user.dart';
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
import '../state/section_content_actions.dart';

class SectionContentScreen extends StatelessWidget {
  const SectionContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<DoctorAssistantAppState, _SectionVm>(
      converter: (store) => _SectionVm.fromStore(store),
      onInit: (store) => store.dispatch(LoadSectionContentAction()),
      builder: (context, vm) {
        final user = vm.user;
        if (user == null) return const SizedBox.shrink();

        return AppShell(
          user: user,
          title: 'Section Content',
          activePath: AppRoutes.sectionContent,
          items: buildNavigationItems(user),
          trailing: user.hasPermission('section_content.create')
              ? AppButton(
                  label: 'New section',
                  icon: Icons.add_rounded,
                  onPressed: () => _showSectionSheet(context, vm.onSave),
                )
              : null,
          body: vm.items == null
              ? const LoadingStateView()
              : ListView(
                  children: vm.items!
                      .map(
                        (SectionContentModel item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AppCard(
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(item.title),
                              subtitle: Text(
                                'Week ${item.weekNumber} • ${item.assistantName}',
                              ),
                              trailing: AppBadge(
                                label: item.isPublished ? 'Published' : 'Draft',
                              ),
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

Future<void> _showSectionSheet(
  BuildContext context,
  void Function(Map<String, dynamic>) onSave,
) {
  final titleController = TextEditingController();

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
            AppButton(
              label: 'Save section content',
              onPressed: () {
                onSave({'title': titleController.text.trim()});
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );
}

class _SectionVm {
  const _SectionVm({
    required this.user,
    required this.items,
    required this.onSave,
  });

  final SessionUser? user;
  final List<SectionContentModel>? items;
  final void Function(Map<String, dynamic>) onSave;

  factory _SectionVm.fromStore(Store<DoctorAssistantAppState> store) {
    return _SectionVm(
      user: getCurrentUser(store.state),
      items: store.state.sectionContentState.data,
      onSave: (payload) => store.dispatch(SaveSectionContentAction(payload)),
    );
  }
}
