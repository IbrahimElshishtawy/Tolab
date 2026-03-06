import 'subjects_state.dart';
import 'subjects_actions.dart';
import 'announcements_actions.dart';
import 'attendance_actions.dart';
import 'reporting_actions.dart';
import '../data/announcement_model.dart';
import '../data/models.dart';

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

  if (action is FetchSubjectContentSuccessAction) {
    final newLectures = Map<int, List<Lecture>>.from(state.lectures);
    final newSections = Map<int, List<Section>>.from(state.sections);
    final newQuizzes = Map<int, List<Quiz>>.from(state.quizzes);
    final newSummaries = Map<int, List<Summary>>.from(state.summaries);

    newLectures[action.subjectId] = action.lectures;
    newSections[action.subjectId] = action.sections;
    newQuizzes[action.subjectId] = action.quizzes;
    newSummaries[action.subjectId] = action.summaries;

    return state.copyWith(
      lectures: newLectures,
      sections: newSections,
      quizzes: newQuizzes,
      summaries: newSummaries,
    );
  }

  if (action is AddSummaryAction) {
    final newSummaries = Map<int, List<Summary>>.from(state.summaries);
    final subjectSummaries = List<Summary>.from(newSummaries[action.subjectId] ?? []);
    subjectSummaries.add(action.summary);
    newSummaries[action.subjectId] = subjectSummaries;
    return state.copyWith(summaries: newSummaries);
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
