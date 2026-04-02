import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/navigation/navigation_items.dart';
import '../../../core/state/async_state.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/state_views.dart';
import '../../../state/app_state.dart';
import '../../auth/state/session_selectors.dart';
import '../state/dashboard_actions.dart';
import '../state/dashboard_state.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<DoctorAssistantAppState, _DashboardViewModel>(
      converter: (store) => _DashboardViewModel.fromStore(store),
      onInit: (store) => store.dispatch(LoadDashboardAction()),
      builder: (context, vm) {
        final user = vm.user;
        if (user == null) {
          return const SizedBox.shrink();
        }

        return AppShell(
          user: user,
          title: 'Overview',
          activePath: AppRoutes.dashboard,
          items: buildNavigationItems(user),
          body: _DashboardBody(vm: vm),
          trailing: AppBadge(label: user.roleType.toUpperCase()),
        );
      },
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.vm});

  final _DashboardViewModel vm;

  @override
  Widget build(BuildContext context) {
    final state = vm.state;
    if (state.status == ViewStatus.loading && state.data == null) {
      return const LoadingStateView();
    }

    if (state.status == ViewStatus.failure && state.data == null) {
      return ErrorStateView(message: state.error ?? 'Failed to load dashboard');
    }

    final snapshot = state.data;
    if (snapshot == null) {
      return const EmptyStateView(
        title: 'No dashboard data',
        message: 'Your assignments will appear here after admin setup.',
      );
    }

    return ListView(
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: snapshot.metrics
              .map(
                (metric) => SizedBox(
                  width: 220,
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(metric.label),
                        const SizedBox(height: 8),
                        Text(
                          metric.value,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(metric.caption),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Upcoming', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              for (final item in snapshot.upcoming)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(child: Icon(Icons.event_rounded)),
                  title: Text(item['title']?.toString() ?? ''),
                  subtitle: Text(item['subtitle']?.toString() ?? ''),
                  trailing: AppBadge(label: item['tag']?.toString() ?? 'Next'),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DashboardViewModel {
  const _DashboardViewModel({
    required this.user,
    required this.state,
  });

  final SessionUser? user;
  final DashboardState state;

  factory _DashboardViewModel.fromStore(Store<DoctorAssistantAppState> store) {
    return _DashboardViewModel(
      user: getCurrentUser(store.state),
      state: store.state.dashboardState,
    );
  }
}
