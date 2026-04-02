import '../../../core/models/content_models.dart';
import '../../../core/state/async_state.dart';

class LecturesState extends AsyncState<List<LectureModel>> {
  const LecturesState({
    super.status,
    super.data,
    super.error,
  });
}
