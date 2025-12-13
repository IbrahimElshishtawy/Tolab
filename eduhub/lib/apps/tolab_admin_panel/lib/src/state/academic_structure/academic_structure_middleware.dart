// ignore_for_file: file_names

import 'package:eduhub/apps/tolab_admin_panel/lib/src/state/app_state.dart';
import 'package:eduhub/fake_data/data.dart';
import 'package:redux/redux.dart';
import 'academic_structure_actions.dart';

List<Middleware<AppState>> academicStructureMiddleware() {
  return [
    TypedMiddleware<AppState, LoadAcademicStructureAction>(_loadStructure).call,
  ];
}

void _loadStructure(
  Store<AppState> store,
  LoadAcademicStructureAction action,
  NextDispatcher next,
) async {
  next(action);

  try {
    await Future.delayed(const Duration(milliseconds: 300));

    final depSet = <String>{};
    final programSet = <String>{};

    for (var student in student) {
      depSet.add(student["department"]);
      final subjectMap = student["subjects_grades"] as Map<String, dynamic>;
      programSet.addAll(subjectMap.keys);
    }
    final years = [1, 2, 3, 4];

    store.dispatch(
      AcademicStructureLoadedAction(
        departments: depSet.toList(),
        programs: programSet.toList(),
        years: years,
      ),
    );
  } catch (e) {
    store.dispatch(AcademicStructureFailedAction(e.toString()));
  }
}
