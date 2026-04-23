import '../../../core/state/async_state.dart';
import '../models/group_models.dart';

class GroupsState extends AsyncState<SubjectGroupModel> {
  const GroupsState({
    super.status,
    super.data,
    super.error,
  });
}
