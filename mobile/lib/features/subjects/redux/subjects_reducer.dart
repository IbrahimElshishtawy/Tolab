import 'subjects_state.dart';
import 'subjects_actions.dart';
import 'announcements_actions.dart';
import 'attendance_actions.dart';
import 'reporting_actions.dart';
import '../data/announcement_model.dart';

SubjectsState subjectsReducer(SubjectsState state, dynamic action) {
  if (action is FetchSubjectsStartAction) {
    return state.copyWith(isLoading: true, error: null);
  }
  if (action is FetchSubjectsSuccessAction) {
    return state.copyWith(
      subjects: action.subjects,
      isLoading: false,
    );
  }
  if (action is FetchSubjectsFailureAction) {
    return state.copyWith(
      isLoading: false,
      error: action.error,
    );
  }

  if (action is FetchAnnouncementsSuccessAction) {
    final newAnnouncements = Map<int, List<Announcement>>.from(state.announcements);
    newAnnouncements[action.subjectId] = action.announcements;
    return state.copyWith(announcements: newAnnouncements);
  }

  if (action is FetchAttendanceSuccessAction) {
    final newAttendance = Map<int, List<dynamic>>.from(state.attendance);
    newAttendance[action.subjectId] = action.data;
    return state.copyWith(attendance: newAttendance);
  }

  if (action is FetchGradebookSuccessAction) {
    final newGradebooks = Map<int, List<dynamic>>.from(state.gradebooks);
    newGradebooks[action.subjectId] = action.gradebook;
    return state.copyWith(gradebooks: newGradebooks);
  }

  if (action is FetchProgressSuccessAction) {
    final newProgress = Map<int, dynamic>.from(state.studentProgress);
    newProgress[action.subjectId] = action.progress;
    return state.copyWith(studentProgress: newProgress);
  }

  return state;
}
