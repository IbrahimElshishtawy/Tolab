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
  {'id': 1, 'title': 'New Material', 'message': 'Dr. Ahmed uploaded Lecture 4'},
  {'id': 2, 'title': 'Task Graded', 'message': 'Your submission for Task 1 has been graded'},
];

final List<Map<String, dynamic>> mockSubmissionsData = [
  {
    'id': 1,
    'task_id': 1,
    'student_name': 'Ali Mohamed',
    'file_url': 'https://example.com/sub1.zip',
    'grade': 'A',
    'submitted_at': '2023-10-24T10:00:00Z',
  },
  {
    'id': 2,
    'task_id': 1,
    'student_name': 'Sara Hassan',
    'file_url': 'https://example.com/sub2.zip',
    'grade': null,
    'submitted_at': '2023-10-24T11:30:00Z',
  },
  {
    'id': 3,
    'task_id': 2,
    'student_name': 'Omar Khaled',
    'file_url': 'https://example.com/sub3.zip',
    'grade': 'B+',
    'submitted_at': '2023-10-31T09:15:00Z',
  },
];

final List<Map<String, dynamic>> mockQuizzesData = [
  {
    'id': 1,
    'title': 'Midterm Quiz',
    'subject_id': 1,
    'start_at': '2023-11-12T09:00:00Z',
    'end_at': '2023-11-12T10:00:00Z',
    'duration': 60,
    'total_points': 20,
  },
  {
    'id': 2,
    'title': 'Redux Fundamentals',
    'subject_id': 2,
    'start_at': '2023-11-15T14:00:00Z',
    'end_at': '2023-11-15T14:30:00Z',
    'duration': 30,
    'total_points': 10,
  },
];

final List<Map<String, dynamic>> mockCalendarEventsData = [
  {
    'id': 1,
    'title': 'Introduction to CS',
    'type': 'lecture',
    'start_at': '2023-11-15T08:30:00Z',
    'location': 'Lecture Hall A',
    'deep_link': 'lms://subjects/1',
  },
  {
    'id': 2,
    'title': 'Environment Setup Due',
    'type': 'task',
    'start_at': '2023-11-15T23:59:59Z',
    'location': 'Online',
    'deep_link': 'lms://tasks/1',
  },
];

final List<Map<String, dynamic>> mockCommentsData = [
  {'id': 1, 'post_id': 1, 'user': 'Ali', 'text': 'Great post!', 'created_at': '2023-11-10T10:00:00Z'},
  {'id': 2, 'post_id': 1, 'user': 'Sara', 'text': 'Very helpful.', 'created_at': '2023-11-10T11:00:00Z'},
];
