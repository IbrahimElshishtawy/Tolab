import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:tolab_fci/redux/state/app_state.dart';
import 'package:tolab_fci/features/home/presentation/widgets/course_card.dart';
import 'subject_details_screen.dart';

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Subjects'),
      ),
      body: StoreConnector<AppState, List<dynamic>>(
        converter: (store) => [], // TODO: Replace with subjects from state
        builder: (context, subjects) {
          // Dummy data for now if list is empty
          final displaySubjects = subjects.isEmpty ? [
            {'name': 'Introduction to Computer Science', 'code': 'CS101', 'id': 1},
            {'name': 'Software Engineering', 'code': 'SWE311', 'id': 2},
          ] : subjects;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: displaySubjects.length,
            itemBuilder: (context, index) {
              final subject = displaySubjects[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: CourseCard(
                  courseName: subject['name'],
                  courseCode: subject['code'],
                  studentsCount: 'Active',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubjectDetailsScreen(subjectId: subject['id'], title: subject['name']),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
