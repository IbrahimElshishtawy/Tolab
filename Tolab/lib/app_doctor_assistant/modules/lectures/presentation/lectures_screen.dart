import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:redux/redux.dart';

import '../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../../app_admin/shared/widgets/premium_button.dart';
import '../../../core/models/content_models.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/state/async_state.dart';
import '../../../core/widgets/state_views.dart';
import '../../../presentation/widgets/doctor_assistant_shell.dart';
import '../../../presentation/widgets/doctor_assistant_widgets.dart';
import '../../../state/app_state.dart';
import '../../auth/state/session_selectors.dart';
import '../../lectures/state/lectures_actions.dart';
import '../../subjects/state/subjects_actions.dart';
import 'widgets/lecture_card.dart';

class LecturesScreen extends StatefulWidget {
  const LecturesScreen({super.key});

  @override
  State<LecturesScreen> createState() => _LecturesScreenState();
}

class _LecturesScreenState extends State<LecturesScreen> {
  String _status = 'All';

  @override
  Widget build(BuildContext context) {
    return StoreConnector<DoctorAssistantAppState, _LecturesVm>(
      onInit: (store) {
        store.dispatch(LoadLecturesAction());
        store.dispatch(LoadSubjectsAction());
      },
      converter: (store) => _LecturesVm.fromStore(store),
      builder: (context, vm) {
        if (vm.user == null) {
          return const SizedBox.shrink();
        }

        final lectures = (vm.lectures.data ?? const <LectureModel>[])
            .where((lecture) {
              if (_status == 'All') {
                return true;
              }
              return lecture.statusLabel.toLowerCase() == _status.toLowerCase();
            })
            .toList(growable: false);

        return DoctorAssistantShell(
          user: vm.user!,
          activeRoute: AppRoutes.lectures,
          unreadNotifications: 0,
          child: DoctorAssistantPageScaffold(
            title: 'Lectures Planner',
            subtitle:
                'Publish, schedule, and review lecture delivery only for the subjects assigned to the current teaching account.',
            breadcrumbs: const ['Workspace', 'Lectures'],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: 220,
                      child: DropdownButtonFormField<String>(
                        initialValue: _status,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: const ['All', 'Draft', 'Scheduled', 'Published', 'Delivered']
                            .map(
                              (value) => DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (value) {
                          setState(() {
                            _status = value ?? 'All';
                          });
                        },
                      ),
                    ),
                    PremiumButton(
                      label: 'Add Lecture',
                      icon: Icons.add_rounded,
                      onPressed: () => context.go(AppRoutes.addLecture),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                if (vm.lectures.status == ViewStatus.loading &&
                    (vm.lectures.data?.isEmpty ?? true))
                  const LoadingStateView(lines: 3)
                else if (vm.lectures.status == ViewStatus.failure &&
                    (vm.lectures.data?.isEmpty ?? true))
                  ErrorStateView(
                    message: vm.lectures.error ?? 'Unable to load lectures.',
                    onRetry: vm.reload,
                  )
                else if (lectures.isEmpty)
                  const EmptyStateView(
                    title: 'No lectures scheduled',
                    message:
                        'Create a lecture draft or schedule one for a published release window.',
                  )
                else
                  Column(
                    children: lectures
                        .map(
                          (lecture) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: LectureCard(
                              lecture: lecture,
                              onEdit: () => context.go(AppRoutes.editLecture(lecture.id)),
                              onPublish: () =>
                                  vm.publishLecture(lecture.id),
                              onCopyLink: () async {
                                await Clipboard.setData(
                                  ClipboardData(
                                    text: lecture.meetingUrl ??
                                        lecture.videoUrl ??
                                        'tolab://lectures/${lecture.id}',
                                  ),
                                );
                                if (!context.mounted) {
                                  return;
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Lecture link copied.'),
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                        .toList(growable: false),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LecturesVm {
  const _LecturesVm({
    required this.user,
    required this.lectures,
    required this.reload,
    required this.publishLecture,
  });

  final dynamic user;
  final AsyncState<List<LectureModel>> lectures;
  final VoidCallback reload;
  final void Function(int lectureId) publishLecture;

  factory _LecturesVm.fromStore(Store<DoctorAssistantAppState> store) {
    return _LecturesVm(
      user: getCurrentUser(store.state),
      lectures: store.state.lecturesState,
      reload: () => store.dispatch(LoadLecturesAction()),
      publishLecture: (lectureId) => store.dispatch(PublishLectureAction(lectureId)),
    );
  }
}
