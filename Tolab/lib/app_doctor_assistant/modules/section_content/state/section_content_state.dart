import '../../../core/models/content_models.dart';
import '../../../core/state/async_state.dart';

class SectionContentState extends AsyncState<List<SectionContentModel>> {
  const SectionContentState({
    super.status,
    super.data,
    super.error,
  });
}
