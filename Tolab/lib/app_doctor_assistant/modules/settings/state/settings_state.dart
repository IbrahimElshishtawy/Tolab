import '../../../core/models/session_user.dart';
import '../../../core/state/async_state.dart';

class SettingsState extends AsyncState<SessionUser> {
  const SettingsState({
    super.status,
    super.data,
    super.error,
  });
}
