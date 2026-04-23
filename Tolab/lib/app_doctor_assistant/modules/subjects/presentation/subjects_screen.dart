import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:redux/redux.dart';

import '../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../core/models/academic_models.dart';
import '../../../core/models/session_user.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/state/async_state.dart';
import '../../../core/widgets/state_views.dart';
import '../../../presentation/widgets/doctor_assistant_shell.dart';
import '../../../presentation/widgets/doctor_assistant_widgets.dart';
import '../../../state/app_state.dart';
import '../../auth/state/session_selectors.dart';
import '../../subjects/state/subjects_actions.dart';
import '../presentation/widgets/subject_card.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _statusFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<DoctorAssistantAppState, _SubjectsVm>(
      onInit: (store) => store.dispatch(LoadSubjectsAction()),
      converter: (store) => _SubjectsVm.fromStore(store),
      builder: (context, vm) {
        final user = vm.user;
        if (user == null) {
          return const SizedBox.shrink();
        }

        final query = _searchController.text.trim().toLowerCase();
        final subjects = (vm.state.data ?? const [])
            .where((subject) {
              final matchesQuery =
                  query.isEmpty ||
                  subject.name.toLowerCase().contains(query) ||
                  subject.code.toLowerCase().contains(query);
              final matchesStatus = _statusFilter == 'All' ||
                  subject.statusLabel.toLowerCase() ==
                      _statusFilter.toLowerCase();
              return matchesQuery && matchesStatus;
            })
            .toList(growable: false);

        return DoctorAssistantShell(
          user: user,
          activeRoute: AppRoutes.subjects,
          unreadNotifications: 0,
          child: DoctorAssistantPageScaffold(
            title: 'Subjects Workspace',
            subtitle:
                'A structured academic workspace for assigned subjects, delivery progress, discussion load, and grading readiness.',
            breadcrumbs: const ['Workspace', 'Subjects'],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: 320,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search_rounded),
                          hintText: 'Search by subject name or code',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 220,
                      child: DropdownButtonFormField<String>(
                        initialValue: _statusFilter,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                        ),
                        items: const ['All', 'Healthy', 'Watch', 'Needs review']
                            .map(
                              (value) => DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (value) {
                          setState(() {
                            _statusFilter = value ?? 'All';
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                if (vm.state.status == ViewStatus.loading &&
                    (vm.state.data?.isEmpty ?? true))
                  const LoadingStateView(lines: 4)
                else if (vm.state.status == ViewStatus.failure &&
                    (vm.state.data?.isEmpty ?? true))
                  ErrorStateView(
                    message: vm.state.error ?? 'Failed to load subjects.',
                    onRetry: vm.reload,
                  )
                else if (subjects.isEmpty)
                  const EmptyStateView(
                    title: 'No assigned subjects',
                    message:
                        'Assigned teaching subjects will appear here with their progress, activity, and grading signals.',
                  )
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 1280
                          ? 3
                          : constraints.maxWidth >= 760
                          ? 2
                          : 1;
                      final spacing = AppSpacing.md;
                      final cardWidth =
                          (constraints.maxWidth - ((columns - 1) * spacing)) /
                              columns;

                      return Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: subjects
                            .map(
                              (subject) => SizedBox(
                                width: cardWidth,
                                child: SubjectCard(
                                  subject: subject,
                                  onOpen: () =>
                                      context.go(AppRoutes.subjectDetails(subject.id)),
                                ),
                              ),
                            )
                            .toList(growable: false),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SubjectsVm {
  const _SubjectsVm({
    required this.user,
    required this.state,
    required this.reload,
  });

  final SessionUser? user;
  final AsyncState<List<SubjectModel>> state;
  final VoidCallback reload;

  factory _SubjectsVm.fromStore(Store<DoctorAssistantAppState> store) {
    return _SubjectsVm(
      user: getCurrentUser(store.state),
      state: store.state.subjectsState.list,
      reload: () => store.dispatch(LoadSubjectsAction()),
    );
  }
}
