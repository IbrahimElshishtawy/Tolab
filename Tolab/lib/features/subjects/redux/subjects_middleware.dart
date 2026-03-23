import 'package:redux/redux.dart';
import '../../../redux/app_state.dart';
import '../../../config/env.dart';
import '../data/subjects_api.dart';
import '../../../mock/fake_repositories/subjects_fake_repo.dart';
import 'subjects_actions.dart';
import 'announcements_actions.dart';
import '../data/announcements_api.dart';
import '../data/announcement_model.dart';
import 'attendance_actions.dart';
import '../data/attendance_api.dart';
import '../data/attendance_model.dart';
import 'reporting_actions.dart';
import '../data/reporting_api.dart';
import '../data/reporting_models.dart';

List<Middleware<AppState>> createSubjectsMiddlewares() {
  return [
    TypedMiddleware<AppState, FetchSubjectsAction>(
      _fetchSubjectsMiddleware,
    ).call,
    TypedMiddleware<AppState, FetchAnnouncementsAction>(
      _fetchAnnouncementsMiddleware,
    ).call,
    TypedMiddleware<AppState, CreateAnnouncementAction>(
      _createAnnouncementMiddleware,
    ).call,
    TypedMiddleware<AppState, DeleteAnnouncementAction>(
      _deleteAnnouncementMiddleware,
    ).call,
    TypedMiddleware<AppState, FetchAttendanceAction>(
      _fetchAttendanceMiddleware,
    ).call,
    TypedMiddleware<AppState, StartAttendanceSessionAction>(
      _startAttendanceMiddleware,
    ).call,
    TypedMiddleware<AppState, CheckInAction>(_checkInMiddleware).call,
    TypedMiddleware<AppState, FetchGradebookAction>(
      _fetchGradebookMiddleware,
    ).call,
    TypedMiddleware<AppState, FetchProgressAction>(
      _fetchProgressMiddleware,
    ).call,
    TypedMiddleware<AppState, FetchSubjectContentAction>(
      _fetchSubjectContentMiddleware,
    ).call,
  ];
}

void _fetchSubjectContentMiddleware(
  Store<AppState> store,
  FetchSubjectContentAction action,
  NextDispatcher next,
) async {
  next(action);
  try {
    if (Env.useMock) {
      final repo = SubjectsFakeRepo();
      final lectures = await repo.getLectures(action.subjectId);
      final sections = await repo.getSections(action.subjectId);
      final quizzes = await repo.getQuizzes(action.subjectId);
      final summaries = await repo.getSummaries(action.subjectId);

      store.dispatch(FetchSubjectContentSuccessAction(
        subjectId: action.subjectId,
        lectures: lectures,
        sections: sections,
        quizzes: quizzes,
        summaries: summaries,
      ));
    }
  } catch (e) {
    // Handle error
  }
}

void _fetchSubjectsMiddleware(
  Store<AppState> store,
  FetchSubjectsAction action,
  NextDispatcher next,
) async {
  next(action);

  store.dispatch(FetchSubjectsStartAction());

  try {
    List<dynamic> subjects;
    if (Env.useMock) {
      final repo = SubjectsFakeRepo();
      subjects = await repo.getSubjects();
    } else {
      final api = SubjectsApi();
      final response = await api.getSubjects();
      subjects = response.data;
    }
    store.dispatch(FetchSubjectsSuccessAction(subjects.cast()));
  } catch (e) {
    store.dispatch(FetchSubjectsFailureAction(e.toString()));
  }
}

void _fetchAnnouncementsMiddleware(
  Store<AppState> store,
  FetchAnnouncementsAction action,
  NextDispatcher next,
) async {
  next(action);
  try {
    final api = AnnouncementsApi();
    final response = await api.getAnnouncements(action.subjectId);
    final announcements = (response.data as List)
        .map((e) => Announcement.fromJson(e))
        .toList();
    store.dispatch(
      FetchAnnouncementsSuccessAction(action.subjectId, announcements),
    );
  } catch (e) {
    // Handle error
  }
}

void _createAnnouncementMiddleware(
  Store<AppState> store,
  CreateAnnouncementAction action,
  NextDispatcher next,
) async {
  next(action);
  try {
    final api = AnnouncementsApi();
    await api.createAnnouncement(action.subjectId, {
      'title': action.title,
      'body': action.body,
      'pinned': action.pinned,
    });
    store.dispatch(FetchAnnouncementsAction(action.subjectId));
  } catch (e) {
    // Handle error
  }
}

void _deleteAnnouncementMiddleware(
  Store<AppState> store,
  DeleteAnnouncementAction action,
  NextDispatcher next,
) async {
  next(action);
  try {
    final api = AnnouncementsApi();
    await api.deleteAnnouncement(action.id);
    store.dispatch(FetchAnnouncementsAction(action.subjectId));
  } catch (e) {
    // Handle error
  }
}

void _fetchAttendanceMiddleware(
  Store<AppState> store,
  FetchAttendanceAction action,
  NextDispatcher next,
) async {
  next(action);
  try {
    final api = AttendanceApi();
    final response = await api.getAttendanceHistory(action.subjectId);
    final role = store.state.authState.role;
    List<dynamic> data;
    if (role == 'student') {
      data = (response.data as List)
          .map((e) => AttendanceRecord.fromJson(e))
          .toList();
    } else {
      data = (response.data as List)
          .map((e) => AttendanceSession.fromJson(e))
          .toList();
    }
    store.dispatch(FetchAttendanceSuccessAction(action.subjectId, data));
  } catch (e) {
    // Handle error
  }
}

void _startAttendanceMiddleware(
  Store<AppState> store,
  StartAttendanceSessionAction action,
  NextDispatcher next,
) async {
  next(action);
  try {
    final api = AttendanceApi();
    await api.startSession(action.subjectId, action.type, action.duration);
    store.dispatch(FetchAttendanceAction(action.subjectId));
  } catch (e) {
    // Handle error
  }
}

void _checkInMiddleware(
  Store<AppState> store,
  CheckInAction action,
  NextDispatcher next,
) async {
  next(action);
  try {
    final api = AttendanceApi();
    await api.checkIn(action.sessionId, action.code);
    // Success - maybe we should refresh history
  } catch (e) {
    // Handle error
  }
}

void _fetchGradebookMiddleware(
  Store<AppState> store,
  FetchGradebookAction action,
  NextDispatcher next,
) async {
  next(action);
  try {
    final api = ReportingApi();
    final response = await api.getGradebook(action.subjectId);
    final gradebook = (response.data as List)
        .map((e) => GradebookEntry.fromJson(e))
        .toList();
    store.dispatch(FetchGradebookSuccessAction(action.subjectId, gradebook));
  } catch (e) {
    // Handle error
  }
}

void _fetchProgressMiddleware(
  Store<AppState> store,
  FetchProgressAction action,
  NextDispatcher next,
) async {
  next(action);
  try {
    final api = ReportingApi();
    final response = await api.getProgress(action.subjectId);
    final progress = StudentProgress.fromJson(response.data);
    store.dispatch(FetchProgressSuccessAction(action.subjectId, progress));
  } catch (e) {
    // Handle error
  }
}
