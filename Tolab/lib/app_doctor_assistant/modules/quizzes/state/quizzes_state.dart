import '../../../core/models/content_models.dart';
import '../../../core/state/async_state.dart';

class QuizzesState extends AsyncState<List<QuizModel>> {
  const QuizzesState({
    super.status,
    super.data,
    super.error,
  });
}
