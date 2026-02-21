import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../../../../redux/app_state.dart';
import '../lecture_form_screen.dart';
import '../section_form_screen.dart';
import '../quiz_form_screen.dart';
import '../quiz_details_screen.dart';
import '../../data/models.dart';

class SubjectOverview extends StatelessWidget {
  final int subjectId;
  const SubjectOverview({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Course Description',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'This course covers the fundamental concepts of the subject, including both theoretical foundations and practical applications.',
          ),
          const SizedBox(height: 20),
          const Text(
            'Instructor',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text('Dr. Ahmed Ali'),
            subtitle: Text('Professor of Computer Science'),
          ),
        ],
      ),
    );
  }
}

class LecturesList extends StatelessWidget {
  final int subjectId;
  const LecturesList({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, bool>(
      converter: (store) =>
          store.state.authState.role == 'doctor' ||
          store.state.authState.role == 'assistant',
      builder: (context, isEducator) {
        return Scaffold(
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                  title: Text('Lecture ${index + 1}: Topic Name'),
                  subtitle: const Text('PDF - 2.5 MB'),
                  trailing: const Icon(Icons.download),
                  onTap: () {},
                ),
              );
            },
          ),
          floatingActionButton: isEducator
              ? FloatingActionButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LectureFormScreen(subjectId: subjectId),
                    ),
                  ),
                  child: const Icon(Icons.add),
                )
              : null,
        );
      },
    );
  }
}

class SectionsList extends StatelessWidget {
  final int subjectId;
  const SectionsList({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, bool>(
      converter: (store) =>
          store.state.authState.role == 'doctor' ||
          store.state.authState.role == 'assistant',
      builder: (context, isEducator) {
        return Scaffold(
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 2,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.slideshow, color: Colors.blue),
                  title: Text('Lab Section ${index + 1}'),
                  subtitle: const Text('Materials & Lab Sheet'),
                  trailing: const Icon(Icons.link),
                  onTap: () {},
                ),
              );
            },
          ),
          floatingActionButton: isEducator
              ? FloatingActionButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SectionFormScreen(subjectId: subjectId),
                    ),
                  ),
                  child: const Icon(Icons.add),
                )
              : null,
        );
      },
    );
  }
}

class QuizzesList extends StatelessWidget {
  final int subjectId;
  const QuizzesList({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, bool>(
      converter: (store) =>
          store.state.authState.role == 'doctor' ||
          store.state.authState.role == 'assistant',
      builder: (context, isEducator) {
        final mockQuiz = Quiz(
          id: 1,
          title: 'Midterm Quiz',
          subjectId: subjectId,
          startAt: DateTime.now().add(const Duration(days: 2)),
          endAt: DateTime.now().add(const Duration(days: 2, hours: 1)),
          durationMins: 60,
          totalPoints: 20,
        );
        return Scaffold(
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 1,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.quiz, color: Colors.purple),
                  title: Text(mockQuiz.title),
                  subtitle: Text(
                    'Start: ${mockQuiz.startAt.toLocal().toString().split('.')[0]}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuizDetailsScreen(quiz: mockQuiz),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          floatingActionButton: isEducator
              ? FloatingActionButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuizFormScreen(subjectId: subjectId),
                    ),
                  ),
                  child: const Icon(Icons.add),
                )
              : null,
        );
      },
    );
  }
}
