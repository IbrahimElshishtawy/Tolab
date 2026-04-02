import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/navigation/navigation_items.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/state_views.dart';
import '../../../state/app_state.dart';
import '../../auth/state/session_selectors.dart';
import '../state/subjects_actions.dart';

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<DoctorAssistantAppState, _SubjectsVm>(
      converter: (store) => _SubjectsVm.fromStore(store),
      onInit: (store) => store.dispatch(LoadSubjectsAction()),
      builder: (context, vm) {
        final user = vm.user;
        if (user == null) return const SizedBox.shrink();

        final subjects = vm.subjects;
        return AppShell(
          user: user,
          title: 'Assigned Subjects',
          activePath: AppRoutes.subjects,
          items: buildNavigationItems(user),
          body: subjects == null
              ? const LoadingStateView()
              : ListView.separated(
                  itemCount: subjects.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final subject = subjects[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () => context.push('${AppRoutes.subjects}/${subject.id}'),
                      child: AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    subject.name,
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                ),
                                AppBadge(label: subject.code),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(subject.departmentName),
                            const SizedBox(height: 8),
                            Text(
                              subject.description ?? subject.academicYearName,
                            ),
                          ],
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

class _SubjectsVm {
  const _SubjectsVm({
    required this.user,
    required this.subjects,
  });

  final SessionUser? user;
  final List<SubjectModel>? subjects;

  factory _SubjectsVm.fromStore(Store<DoctorAssistantAppState> store) {
    return _SubjectsVm(
      user: getCurrentUser(store.state),
      subjects: store.state.subjectsState.list.data,
    );
  }
}
