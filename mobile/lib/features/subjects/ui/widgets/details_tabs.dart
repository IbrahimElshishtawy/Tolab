import 'package:flutter/material.dart';

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
          const Text('Course Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text('This course covers the fundamental concepts of the subject, including both theoretical foundations and practical applications.'),
          const SizedBox(height: 20),
          const Text('Instructor', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
    return ListView.builder(
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
    );
  }
}

class SectionsList extends StatelessWidget {
  final int subjectId;
  const SectionsList({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
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
    );
  }
}

class QuizzesList extends StatelessWidget {
  final int subjectId;
  const QuizzesList({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 1,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.quiz, color: Colors.purple),
            title: const Text('Midterm Quiz'),
            subtitle: const Text('Status: Upcoming - Nov 12'),
            trailing: const Icon(Icons.lock_outline),
          ),
        );
      },
    );
  }
}
