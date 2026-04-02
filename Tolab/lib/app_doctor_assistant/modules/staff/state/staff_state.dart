import '../../../core/models/staff_models.dart';
import '../../../core/state/async_state.dart';

class StaffState extends AsyncState<List<StaffMemberModel>> {
  const StaffState({
    super.status,
    super.data,
    super.error,
  });
}
