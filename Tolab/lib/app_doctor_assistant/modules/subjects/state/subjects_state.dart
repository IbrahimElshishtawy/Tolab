import '../../../core/state/async_state.dart';
import '../../../core/models/academic_models.dart';
import '../models/subject_workspace_models.dart';

class SubjectsState {
  const SubjectsState({
    this.list = const AsyncState<List<SubjectModel>>(),
    this.workspace = const AsyncState<SubjectWorkspaceModel>(),
  });

  final AsyncState<List<SubjectModel>> list;
  final AsyncState<SubjectWorkspaceModel> workspace;

  SubjectsState copyWith({
    AsyncState<List<SubjectModel>>? list,
    AsyncState<SubjectWorkspaceModel>? workspace,
  }) {
    return SubjectsState(
      list: list ?? this.list,
      workspace: workspace ?? this.workspace,
    );
  }
}
