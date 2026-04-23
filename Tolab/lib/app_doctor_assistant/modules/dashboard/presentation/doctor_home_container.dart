import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:redux/redux.dart';

import '../../../../app/routing/app_routes.dart' as unified_routes;
import '../../../../app/core/app_scope.dart';
import '../../../core/models/session_user.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../presentation/widgets/doctor_assistant_shell.dart';
import '../../../state/app_state.dart';
import '../../auth/state/session_selectors.dart';
import '../state/dashboard_actions.dart';
import '../state/dashboard_state.dart';
import '../state/dashboard_view_model.dart';
import 'doctor_dashboard_page.dart';
import 'widgets/doctor_home_empty.dart';
import 'widgets/doctor_home_error.dart';
import 'widgets/doctor_home_loading.dart';

class DoctorHomeContainer extends StatelessWidget {
  const DoctorHomeContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<DoctorAssistantAppState, _DoctorHomeVm>(
      onInit: (store) {
        final state = DashboardViewModel.fromStore(store);
        if (state.isInitial || !state.hasData) {
          store.dispatch(const LoadDashboardAction());
        }
      },
      converter: (Store<DoctorAssistantAppState> store) =>
          _DoctorHomeVm.fromStore(store),
      builder: (context, vm) {
        final user =
            vm.user ?? AppScope.auth(context).currentUser?.toSessionUser();
        if (user == null) {
          return Scaffold(
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: DoctorHomeError(
                    title: 'Session unavailable',
                    message:
                        'Your account was restored, but the workspace session is not ready yet. Please return to login and try again.',
                    primaryActionLabel: 'Go to Login',
                    icon: Icons.login_rounded,
                    primaryActionIcon: Icons.arrow_forward_rounded,
                    onPrimaryAction: () =>
                        context.go(unified_routes.UnifiedAppRoutes.login),
                  ),
                ),
              ),
            ),
          );
        }

        if (vm.dashboard.isLoading && !vm.dashboard.hasData) {
          return DoctorAssistantShell(
            user: user,
            activeRoute: AppRoutes.dashboard,
            child: const DoctorHomeLoading(),
          );
        }

        if (vm.dashboard.isFailure && !vm.dashboard.hasData) {
          final isAuthFailure =
              vm.dashboard.failureType == DashboardFailureType.authentication;
          return DoctorAssistantShell(
            user: user,
            activeRoute: AppRoutes.dashboard,
            child: DoctorHomeError(
              title: isAuthFailure
                  ? 'Session expired'
                  : 'Unable to load dashboard',
              message:
                  vm.dashboard.error ??
                  (isAuthFailure
                      ? 'Session expired, please login again.'
                      : 'Unexpected dashboard error.'),
              primaryActionLabel: isAuthFailure ? 'Go to Login' : 'Retry',
              icon: isAuthFailure
                  ? Icons.login_rounded
                  : Icons.wifi_tethering_error_rounded,
              primaryActionIcon: isAuthFailure
                  ? Icons.arrow_forward_rounded
                  : Icons.refresh_rounded,
              onPrimaryAction: isAuthFailure
                  ? () => context.go(unified_routes.UnifiedAppRoutes.login)
                  : () => vm.dashboard.load(force: true),
            ),
          );
        }

        final snapshot = vm.dashboard.snapshot;
        if (snapshot == null || !snapshot.hasContent) {
          return DoctorAssistantShell(
            user: user,
            activeRoute: AppRoutes.dashboard,
            child: DoctorHomeEmpty(
              title: 'Nothing to review yet',
              message:
                  'Assigned subjects, schedule items, or dashboard signals will appear here once the workspace has active data.',
              onRefresh: () => vm.dashboard.load(force: true),
            ),
          );
        }

        return DoctorDashboardPage(
          user: user,
          vm: vm.dashboard,
          onToggleStyle: AppScope.theme(context).toggle,
        );
      },
    );
  }
}

class _DoctorHomeVm {
  const _DoctorHomeVm({required this.user, required this.dashboard});

  final SessionUser? user;
  final DashboardViewModel dashboard;

  factory _DoctorHomeVm.fromStore(Store<DoctorAssistantAppState> store) {
    return _DoctorHomeVm(
      user: getCurrentUser(store.state),
      dashboard: DashboardViewModel.fromStore(store),
    );
  }
}
