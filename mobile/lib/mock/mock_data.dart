import '../features/subjects/data/models.dart';
import '../features/tasks/data/models.dart';

final List<Map<String, dynamic>> mockSubjectsData = [
  {
    'id': 1,
    'code': 'CS101',
    'name': 'Introduction to Computer Science',
    'description': 'Basics of computing and programming.',
  },
  {
    'id': 2,
    'code': 'SWE311',
    'name': 'Software Engineering',
    'description': 'Lifecycle, patterns, and architecture.',
  },
  {
    'id': 3,
    'code': 'IS212',
    'name': 'Database Systems',
    'description': 'Relational databases and SQL.',
  },
];

final List<Map<String, dynamic>> mockLecturesData = [
  {'id': 101, 'title': 'Lecture 1: Intro to binary', 'content_url': 'https://example.com/lec1.pdf'},
  {'id': 102, 'title': 'Lecture 2: Control flow', 'content_url': 'https://example.com/lec2.pdf'},
];

final List<Map<String, dynamic>> mockTasksData = [
  {
    'id': 1,
    'title': 'Environment Setup',
    'description': 'Install VS Code and Flutter.',
    'due_date': '2023-10-25T12:00:00Z',
  },
  {
    'id': 2,
    'title': 'First UI App',
    'description': 'Create a simple counter app.',
    'due_date': '2023-11-01T12:00:00Z',
  },
];

final List<Map<String, dynamic>> mockNotificationsData = [
  {
    'id': 1,
    'title': 'New Material',
    'message': 'Dr. Ahmed uploaded Lecture 4',
    'deep_link': 'lms://subject/1'
  },
  {
    'id': 2,
    'title': 'New Assignment',
    'message': 'Task 2: First UI App has been posted',
    'deep_link': 'lms://task/2'
  },
  {
    'id': 3,
    'title': 'Community Update',
    'message': 'Someone commented on your post',
    'deep_link': 'lms://post/3'
  },
];
