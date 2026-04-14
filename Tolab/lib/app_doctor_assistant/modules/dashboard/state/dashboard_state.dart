import '../../../core/models/dashboard_models.dart';
import '../../../core/state/async_state.dart';

enum DashboardFailureType { none, authentication, network, general }

class DashboardState extends AsyncState<DashboardSnapshot> {
  const DashboardState({
    super.status,
    super.data,
    super.error,
    this.failureType = DashboardFailureType.none,
  });

  final DashboardFailureType failureType;
}
