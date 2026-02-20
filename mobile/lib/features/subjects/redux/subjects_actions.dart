import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import '../data/subjects_api.dart';
import '../data/models.dart';
import '../../../redux/app_state.dart';

class FetchSubjectsStartAction {}

class FetchSubjectsSuccessAction {
  final List<Subject> subjects;
  FetchSubjectsSuccessAction(this.subjects);
}

class FetchSubjectsFailureAction {
  final String error;
  FetchSubjectsFailureAction(this.error);
}

ThunkAction<AppState> fetchSubjectsAction() {
  return (Store<AppState> store) async {
    store.dispatch(FetchSubjectsStartAction());
    try {
      final api = SubjectsApi();
      final response = await api.getSubjects();
      final List<dynamic> data = response.data;
      final subjects = data.map((json) => Subject.fromJson(json)).toList();
      store.dispatch(FetchSubjectsSuccessAction(subjects));
    } catch (e) {
      store.dispatch(FetchSubjectsFailureAction(e.toString()));
    }
  };
}
