import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../../app_admin/modules/schedule/models/schedule_models.dart';
import '../../../../app_admin/modules/schedule/widgets/schedule_calendar_board.dart';
import '../../../core/models/session_user.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../mock/doctor_assistant_mock_repository.dart';
import '../../../presentation/widgets/doctor_assistant_shell.dart';
import '../../../presentation/widgets/doctor_assistant_widgets.dart';
import '../../../state/app_state.dart';
import '../../auth/state/session_selectors.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  ScheduleCalendarView _view = ScheduleCalendarView.week;
  DateTime _focusedDay = DateTime(2026, 4, 6);
  DateTime _selectedDay = DateTime(2026, 4, 6);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<DoctorAssistantAppState, SessionUser?>(
      converter: (store) => getCurrentUser(store.state),
      builder: (context, user) {
        if (user == null) return const SizedBox.shrink();
        final repository = DoctorAssistantMockRepository.instance;
        final events = repository.scheduleFor(user);
        final conflicts = repository.scheduleConflictsFor(user);

        return DoctorAssistantShell(
          user: user,
          activeRoute: AppRoutes.schedule,
          child: DoctorAssistantPageScaffold(
            title: 'Schedule',
            subtitle:
                'Calendar, session cards, and interaction states reuse the admin schedule system directly.',
            breadcrumbs: const ['Workspace', 'Schedule'],
            scrollable: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 1120;
                final agenda = DoctorAssistantPanel(
                  title: 'This Week',
                  subtitle:
                      'Compact agenda cards for upcoming delivery blocks.',
                  expandChild: true,
                  child: ListView.separated(
                    itemCount: events.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return DoctorAssistantItemCard(
                        icon: event.type.icon,
                        title: event.title,
                        subtitle: '${event.subject} • ${event.location}',
                        meta:
                            '${event.section} • ${event.startAt.day}/${event.startAt.month} ${TimeOfDay.fromDateTime(event.startAt).format(context)}',
                        statusLabel: event.status.label,
                        highlightColor: event.type.color,
                      );
                    },
                  ),
                );

                final board = ScheduleCalendarBoard(
                  events: events,
                  view: _view,
                  focusedDay: _focusedDay,
                  selectedDay: _selectedDay,
                  conflictMap: conflicts,
                  onViewChanged: (view) => setState(() => _view = view),
                  onFocusedDayChanged: (day) =>
                      setState(() => _focusedDay = day),
                  onSelectedDayChanged: (day) =>
                      setState(() => _selectedDay = day),
                  onNavigate: (direction) => setState(() {
                    final delta = switch (_view) {
                      ScheduleCalendarView.month => Duration(
                        days: 30 * direction,
                      ),
                      ScheduleCalendarView.week => Duration(
                        days: 7 * direction,
                      ),
                      ScheduleCalendarView.day => Duration(days: direction),
                    };
                    _focusedDay = _focusedDay.add(delta);
                    _selectedDay = _selectedDay.add(delta);
                  }),
                  onEventTap: (_) {},
                  onEventDropped: (event, startAt, endAt) {},
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
        );
      },
    );
  }
}
