import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';

import '../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../../app_admin/modules/schedule/models/schedule_models.dart';
import '../../../../app_admin/modules/schedule/widgets/schedule_calendar_board.dart';
import '../../../core/models/session_user.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../mock/doctor_assistant_mock_repository.dart';
import '../../../presentation/widgets/doctor_assistant_shell.dart';
import '../../../presentation/widgets/doctor_assistant_widgets.dart';
import '../../../presentation/widgets/workspace/faculty_quick_actions_bar.dart';
import '../../../state/app_state.dart';
import '../../auth/state/session_selectors.dart';
import 'models/schedule_workspace_models.dart';
import 'widgets/schedule_agenda_panel.dart';
import 'widgets/schedule_controls_panel.dart';
import 'widgets/schedule_event_details.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  ScheduleCalendarView _view = ScheduleCalendarView.week;
  DateTime _focusedDay = DateTime(2026, 4, 26);
  DateTime _selectedDay = DateTime(2026, 4, 26);
  final Set<FacultyScheduleFilter> _activeFilters =
      FacultyScheduleFilter.values.toSet();
  List<ScheduleEventItem>? _localEvents;
  int? _hydratedUserId;

  void _hydrate(SessionUser user, DoctorAssistantMockRepository repository) {
    if (_hydratedUserId == user.id && _localEvents != null) {
      return;
    }
    _hydratedUserId = user.id;
    _localEvents = repository.scheduleFor(user);
  }

  void _openEventDetails(
    BuildContext context,
    FacultyScheduleItem item,
    List<String> conflictReasons,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return ScheduleEventDetailsSheet(
          item: item,
          conflictReasons: conflictReasons,
          onEdit: () {
            Navigator.of(context).pop();
            final route = switch (item.filter) {
              FacultyScheduleFilter.lectures => AppRoutes.lectures,
              FacultyScheduleFilter.sections => AppRoutes.sectionContent,
              FacultyScheduleFilter.quizzes => AppRoutes.quizzes,
              FacultyScheduleFilter.tasks => AppRoutes.tasks,
              FacultyScheduleFilter.exams => AppRoutes.schedule,
            };
            context.go(route);
          },
          onCancel: () {
            setState(() {
              _localEvents = _localEvents
                  ?.where((event) => event.id != item.event.id)
                  .toList(growable: false);
            });
            Navigator.of(context).pop();
            ScaffoldMessenger.of(this.context).showSnackBar(
              SnackBar(content: Text('${item.event.title} was removed from the current schedule view.')),
            );
          },
          onReschedule: () {
            setState(() {
              _localEvents = _localEvents
                  ?.map(
                    (event) => event.id == item.event.id
                        ? event.copyWith(
                            startAt: event.startAt.add(const Duration(days: 1)),
                            endAt: event.endAt.add(const Duration(days: 1)),
                          )
                        : event,
                  )
                  .toList(growable: false);
            });
            Navigator.of(context).pop();
            ScaffoldMessenger.of(this.context).showSnackBar(
              SnackBar(content: Text('${item.event.title} moved one day forward in the local planner.')),
            );
          },
          onNotifyStudents: () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(this.context).showSnackBar(
              SnackBar(content: Text('Student notification prepared for ${item.event.title}.')),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<DoctorAssistantAppState, SessionUser?>(
      converter: (store) => getCurrentUser(store.state),
      builder: (context, user) {
        if (user == null) {
          return const SizedBox.shrink();
        }
        final repository = DoctorAssistantMockRepository.instance;
        _hydrate(user, repository);
        final events = _localEvents ?? const <ScheduleEventItem>[];
        final workspace = buildScheduleWorkspace(
          events,
          initialConflicts: repository.scheduleConflictsFor(user),
        );
        final filteredEvents = filterScheduleEvents(workspace.items, _activeFilters);

        return DoctorAssistantShell(
          user: user,
          activeRoute: AppRoutes.schedule,
          unreadNotifications: repository.unreadNotificationsFor(user),
          child: DoctorAssistantPageScaffold(
            title: 'Schedule',
            subtitle:
                'Academic planner for day/week/month management, conflict control, and follow-up on events that still need attention.',
            breadcrumbs: const ['Workspace', 'Schedule'],
            scrollable: false,
            child: Column(
              children: [
                FacultyQuickActionsBar(user: user),
                const SizedBox(height: AppSpacing.md),
                ScheduleControlsPanel(
                  activeFilters: _activeFilters,
                  onToggleFilter: (filter) {
                    setState(() {
                      if (_activeFilters.contains(filter) && _activeFilters.length > 1) {
                        _activeFilters.remove(filter);
                      } else {
                        _activeFilters.add(filter);
                      }
                    });
                  },
                  onAddLecture: () => context.go(AppRoutes.addLecture),
                  onAddSection: () => context.go(AppRoutes.sectionContent),
                  onAddQuiz: () => context.go(AppRoutes.quizzes),
                  onAddTask: () => context.go(AppRoutes.tasks),
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 1160;
                      final board = ScheduleCalendarBoard(
                        events: filteredEvents,
                        view: _view,
                        focusedDay: _focusedDay,
                        selectedDay: _selectedDay,
                        conflictMap: workspace.conflicts,
                        onViewChanged: (view) => setState(() => _view = view),
                        onFocusedDayChanged: (day) => setState(() => _focusedDay = day),
                        onSelectedDayChanged: (day) => setState(() => _selectedDay = day),
                        onNavigate: (direction) => setState(() {
                          final delta = switch (_view) {
                            ScheduleCalendarView.month => Duration(days: 30 * direction),
                            ScheduleCalendarView.week => Duration(days: 7 * direction),
                            ScheduleCalendarView.day => Duration(days: direction),
                          };
                          _focusedDay = _focusedDay.add(delta);
                          _selectedDay = _selectedDay.add(delta);
                        }),
                        onEventTap: (event) {
                          final item = workspace.items.firstWhere(
                            (candidate) => candidate.event.id == event.id,
                            orElse: () => FacultyScheduleItem(
                              event: event,
                              filter: FacultyScheduleFilter.lectures,
                              statusLabel: 'Published',
                              followUpLabel: 'Review academic details',
                              hasConflict: false,
                              isMissingContext: false,
                            ),
                          );
                          _openEventDetails(
                            context,
                            item,
                            workspace.conflicts[event.id] ?? const <String>[],
                          );
                        },
                        onEventDropped: (event, startAt, endAt) {
                          setState(() {
                            _localEvents = _localEvents
                                ?.map(
                                  (item) => item.id == event.id
                                      ? item.copyWith(startAt: startAt, endAt: endAt)
                                      : item,
                                )
                                .toList(growable: false);
                          });
                        },
                        onCreateAt: (selectedAt) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Quick add slot selected at ${scheduleDateLabel(selectedAt)}. Use Add Lecture / Add Section / Add Quiz / Add Task above.',
                              ),
                            ),
                          );
                        },
                      );
                      final agenda = ScheduleAgendaPanel(
                        upcoming: workspace.upcomingThisWeek,
                        needsFollowUp: workspace.needsFollowUp,
                        missingContext: workspace.missingContext,
                        onOpenEvent: (item) => _openEventDetails(
                          context,
                          item,
                          workspace.conflicts[item.event.id] ?? const <String>[],
                        ),
                      );

                      if (!isWide) {
                        return Column(
                          children: [
                            Expanded(flex: 7, child: board),
                            const SizedBox(height: AppSpacing.md),
                            Expanded(flex: 5, child: agenda),
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 7, child: board),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(flex: 4, child: agenda),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
