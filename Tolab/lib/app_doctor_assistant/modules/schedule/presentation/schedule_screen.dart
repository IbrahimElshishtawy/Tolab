import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/models/notification_models.dart';
import '../../../core/models/session_user.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/navigation/navigation_items.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/state_views.dart';
import '../../../state/app_state.dart';
import '../../auth/state/session_selectors.dart';
import '../state/schedule_actions.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<DoctorAssistantAppState, _ScheduleVm>(
      converter: (store) => _ScheduleVm.fromStore(store),
      onInit: (store) => store.dispatch(LoadScheduleAction()),
      builder: (context, vm) {
        final user = vm.user;
        if (user == null) return const SizedBox.shrink();

        return AppShell(
          user: user,
          title: 'Schedule',
          activePath: AppRoutes.schedule,
          items: buildNavigationItems(user),
          body: vm.items == null
              ? const LoadingStateView()
              : ListView(
                  children: [
                    AppCard(
                      child: TableCalendar(
                        firstDay: DateTime.utc(2025),
                        lastDay: DateTime.utc(2030),
                        focusedDay: DateTime.now(),
                        calendarFormat: CalendarFormat.week,
                        headerVisible: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...vm.items!.map(
                      (ScheduleEventModel item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AppCard(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(item.title),
                            subtitle: Text(
                              '${item.eventDate} • ${item.startTime ?? '--'} - ${item.endTime ?? '--'}',
                            ),
                            trailing: AppBadge(label: item.eventType),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _ScheduleVm {
  const _ScheduleVm({
    required this.user,
    required this.items,
  });

  final SessionUser? user;
  final List<ScheduleEventModel>? items;

  factory _ScheduleVm.fromStore(Store<DoctorAssistantAppState> store) {
    return _ScheduleVm(
      user: getCurrentUser(store.state),
      items: store.state.scheduleState.data,
    );
  }
}
