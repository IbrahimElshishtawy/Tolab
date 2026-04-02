import '../../../core/models/academic_models.dart';
import '../../../core/state/async_state.dart';

class SubjectsState {
  const SubjectsState({
    this.list = const AsyncState<List<SubjectModel>>(),
    this.detail = const AsyncState<SubjectModel>(),
  });

  final AsyncState<List<SubjectModel>> list;
  final AsyncState<SubjectModel> detail;

  SubjectsState copyWith({
    AsyncState<List<SubjectModel>>? list,
    AsyncState<SubjectModel>? detail,
  }) {
    return SubjectsState(
      list: list ?? this.list,
      detail: detail ?? this.detail,
    );
  }
}
