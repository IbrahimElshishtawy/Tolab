import 'package:redux/redux.dart';

import '../../../core/services/app_dependencies.dart';
import '../../../shared/enums/load_status.dart';
import '../../../shared/states/entity_collection_state.dart';
import '../../../state/app_state.dart';
import '../models/subject_management_models.dart';

typedef SubjectsState = EntityCollectionState<SubjectRecord>;

const SubjectsState initialSubjectsState =
    EntityCollectionState<SubjectRecord>();

class LoadSubjectsAction {}

class SubjectsLoadedAction {
  SubjectsLoadedAction(this.items);

  final List<SubjectRecord> items;
}

class SubjectsFailedAction {
  SubjectsFailedAction(this.message);

  final String message;
}

class CreateGroupAction {
  CreateGroupAction({required this.subjectId, required this.groupName});

  final String subjectId;
  final String groupName;
}

SubjectsState subjectsReducer(SubjectsState state, dynamic action) {
  switch (action) {
    case LoadSubjectsAction():
      return state.copyWith(status: LoadStatus.loading, clearError: true);
    case SubjectsLoadedAction():
      return state.copyWith(status: LoadStatus.success, items: action.items);
    case SubjectsFailedAction():
      return state.copyWith(
        status: LoadStatus.failure,
        errorMessage: action.message,
      );
    case CreateGroupAction():
      final updatedItems = state.items.map((item) {
        if (item.id == action.subjectId) {
          return SubjectRecord(
            id: item.id,
            code: item.code,
            name: item.name,
            department: item.department,
            academicYear: item.academicYear,
            creditHours: item.creditHours,
            contactHours: item.contactHours,
            status: item.status,
            doctor: item.doctor,
            assistant: item.assistant,
            eligibleStudents: item.eligibleStudents,
            enrolledStudents: item.enrolledStudents,
            group: SubjectGroupInfo(
              enabled: true,
              name: action.groupName,
              members: item.enrolledStudents,
              moderationLabel: 'Auto-Moderation',
              engagementLabel: 'High',
            ),
            posts: item.posts,
            summaries: item.summaries,
            access: item.access,
            permissions: item.permissions,
            students: item.students,
            timeline: item.timeline,
            activity: item.activity,
            updatedAtLabel: 'Just now',
            lateRegistrationEnabled: item.lateRegistrationEnabled,
          );
        }
        return item;
      }).toList();
      return state.copyWith(items: updatedItems);
    default:
      return state;
  }
}

List<Middleware<AppState>> createSubjectsMiddleware(AppDependencies deps) {
  return [
    TypedMiddleware<AppState, LoadSubjectsAction>((store, action, next) async {
      next(action);
      try {
        store.dispatch(
          SubjectsLoadedAction(await deps.subjectsRepository.fetchSubjects()),
        );
      } catch (error) {
        store.dispatch(SubjectsFailedAction(error.toString()));
      }
    }).call,
  ];
}
