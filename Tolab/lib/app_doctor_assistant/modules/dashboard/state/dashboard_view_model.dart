import 'package:redux/redux.dart';

import '../../../core/models/dashboard_models.dart';
import '../../../core/state/async_state.dart';
import '../../../state/app_state.dart';
import 'dashboard_actions.dart';
import 'dashboard_selectors.dart';

class DashboardViewModel {
  const DashboardViewModel({
    required this.status,
    required this.snapshot,
    required this.error,
    required this.load,
  });

  final ViewStatus status;
  final DashboardSnapshot? snapshot;
  final String? error;
  final void Function({bool force}) load;

  bool get isInitial => status == ViewStatus.initial;
  bool get isLoading => status == ViewStatus.loading;
  bool get isFailure => status == ViewStatus.failure;
  bool get hasData => snapshot != null;
  bool get isRefreshing => isLoading && hasData;

  factory DashboardViewModel.fromStore(Store<DoctorAssistantAppState> store) {
    final state = getDashboardState(store.state);
    return DashboardViewModel(
      status: state.status,
      snapshot: state.data,
      error: getDashboardError(store.state),
      load: ({bool force = false}) {
        store.dispatch(LoadDashboardAction(force: force));
      },
    );
  }
}
