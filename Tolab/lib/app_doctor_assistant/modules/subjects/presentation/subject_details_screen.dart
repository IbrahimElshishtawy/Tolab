import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/navigation/navigation_items.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/state_views.dart';
import '../../../state/app_state.dart';
import '../../auth/state/session_selectors.dart';
import '../state/subjects_actions.dart';

class SubjectDetailsScreen extends StatelessWidget {
  const SubjectDetailsScreen({
    super.key,
    required this.subjectId,
  });

  final int subjectId;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<DoctorAssistantAppState, _SubjectDetailsVm>(
      converter: (store) => _SubjectDetailsVm.fromStore(store),
      onInit: (store) => store.dispatch(LoadSubjectDetailAction(subjectId)),
      builder: (context, vm) {
        final user = vm.user;
        final subject = vm.subject;
        if (user == null) return const SizedBox.shrink();

        return AppShell(
          user: user,
          title: subject?.name ?? 'Subject details',
          activePath: AppRoutes.subjects,
          items: buildNavigationItems(user),
          body: subject == null
              ? const LoadingStateView(lines: 2)
              : ListView(
                  children: [
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  subject.name,
                                  style:
                                      Theme.of(context).textTheme.headlineMedium,
                                ),
                              ),
                              AppBadge(label: subject.code),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(subject.departmentName),
                          const SizedBox(height: 8),
                          Text(subject.description ?? subject.academicYearName),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sections',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          for (final section in subject.sections)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(section.name),
                              subtitle: Text(section.assistantName ?? 'Pending'),
                              trailing: AppBadge(label: section.code),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _SubjectDetailsVm {
  const _SubjectDetailsVm({
    required this.user,
    required this.subject,
  });

  final SessionUser? user;
  final SubjectModel? subject;

  factory _SubjectDetailsVm.fromStore(Store<DoctorAssistantAppState> store) {
    return _SubjectDetailsVm(
      user: getCurrentUser(store.state),
      subject: store.state.subjectsState.detail.data,
    );
  }
}
