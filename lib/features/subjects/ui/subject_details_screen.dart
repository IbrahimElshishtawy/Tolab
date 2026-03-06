import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../../../redux/app_state.dart';
import 'widgets/details_tabs.dart';
import 'tasks_screen.dart';
import 'subject_submissions_screen.dart';
import 'announcements_screen.dart';
import 'attendance_screen.dart';
import 'progress_screen.dart';
import 'gradebook_screen.dart';

class SubjectDetailsScreen extends StatelessWidget {
  final int subjectId;
  final String title;

  const SubjectDetailsScreen({super.key, required this.subjectId, required this.title});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, bool>(
      converter: (store) {
        final role = store.state.authState.role;
        return role == 'doctor' || role == 'assistant';
      },
      builder: (context, isEducator) {
        return DefaultTabController(
          length: isEducator ? 8 : 7,
          child: Scaffold(
            appBar: AppBar(
              title: Text(title),
              bottom: TabBar(
                isScrollable: true,
                tabs: [
                  const Tab(text: 'Overview'),
                  const Tab(text: 'Announcements'),
                  const Tab(text: 'Attendance'),
                  if (!isEducator) const Tab(text: 'Progress'),
                  if (isEducator) const Tab(text: 'Gradebook'),
                  const Tab(text: 'Lectures'),
                  const Tab(text: 'Sections'),
                  const Tab(text: 'Tasks'),
                  const Tab(text: 'Quizzes'),
                  if (isEducator) const Tab(text: 'Submissions'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                SubjectOverview(subjectId: subjectId),
                AnnouncementsScreen(subjectId: subjectId),
                AttendanceScreen(subjectId: subjectId),
                if (!isEducator) ProgressScreen(subjectId: subjectId),
                if (isEducator) GradebookScreen(subjectId: subjectId),
                LecturesList(subjectId: subjectId),
                SectionsList(subjectId: subjectId),
                TasksScreen(subjectId: subjectId),
                QuizzesList(subjectId: subjectId),
                if (isEducator) SubjectSubmissionsScreen(subjectId: subjectId),
              ],
            ),
          ),
        );
      },
    );
  }
}
