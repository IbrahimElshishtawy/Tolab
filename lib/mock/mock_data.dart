final List<Map<String, dynamic>> mockSubjectsData = [
  {
    'id': 1,
    'code': 'CS311',
    'name': 'Software Engineering',
    'description': 'Lifecycle, patterns, and architecture.',
  },
  {
    'id': 2,
    'code': 'IS212',
    'name': 'Database Systems',
    'description': 'Relational databases and SQL.',
  },
  {
    'id': 3,
    'code': 'CS412',
    'name': 'Algorithms',
    'description': 'Advanced algorithmic design.',
  },
];

final Map<int, List<Map<String, dynamic>>> mockLecturesDataMap = {
  1: [
    {
      'id': 101,
      'week_number': 1,
      'title': 'Introduction to SE',
      'doctor_name': 'Dr. Sarah Smith',
      'content': 'Overview of software engineering principles.',
      'video_url': 'https://youtube.com/watch?v=123',
      'pdf_url': 'https://example.com/lec1.pdf',
    },
    {
      'id': 102,
      'week_number': 2,
      'title': 'Agile Methodologies',
      'doctor_name': 'Dr. Sarah Smith',
      'content': 'Scrum, Kanban, and XP frameworks.',
      'video_url': 'https://youtube.com/watch?v=456',
      'pdf_url': 'https://example.com/lec2.pdf',
    },
  ],
};

final Map<int, List<Map<String, dynamic>>> mockSectionsDataMap = {
  1: [
    {
      'id': 201,
      'week_number': 1,
      'title': 'Git & Version Control',
      'assistant_name': 'Eng. Ali Hassan',
      'content': 'Practical session on Git basics.',
      'video_url': 'https://youtube.com/watch?v=abc',
      'pdf_url': 'https://example.com/sec1.pdf',
    },
  ],
};

final Map<int, List<Map<String, dynamic>>> mockQuizzesDataMap = {
  1: [
    {
      'id': 301,
      'type': 'online',
      'week_number': 3,
      'source_name': 'Lecture 2',
      'owner_name': 'Dr. Sarah Smith',
      'title': 'Agile Basics Quiz',
      'start_at': '2023-10-01T10:00:00Z',
      'quiz_url': 'https://forms.gle/xyz',
      'subject_id': 1,
    },
    {
      'id': 302,
      'type': 'offline',
      'week_number': 4,
      'source_name': 'Section 3',
      'owner_name': 'Eng. Ali Hassan',
      'title': 'Git Commands Quiz',
      'start_at': '2023-10-15T09:00:00Z',
      'subject_id': 1,
    },
  ],
};

final Map<int, List<Map<String, dynamic>>> mockTasksDataMap = {
  1: [
    {
      'id': 401,
      'week_number': 2,
      'source_name': 'Lecture 1',
      'owner_name': 'Dr. Sarah Smith',
      'title': 'SRS Document',
      'description': 'Create a Software Requirement Specification for a library system.',
      'due_date': '2023-11-20T23:59:59Z',
      'pdf_url': 'https://example.com/task1.pdf',
    },
  ],
};

final Map<int, List<Map<String, dynamic>>> mockSummariesDataMap = {
  1: [
    {
      'id': 501,
      'name': 'Agile Summary',
      'student_name': 'Ahmed Mohamed',
      'content': 'A brief summary of Agile principles discussed in Week 2.',
      'video_url': 'https://youtube.com/watch?v=summary1',
    },
  ],
};

final List<Map<String, dynamic>> mockNotificationsData = [
  {
    'id': 1,
    'title': 'New Lecture Uploaded',
    'content': 'Dr. Sarah Smith uploaded Week 3 Lecture.',
    'created_at': '2023-10-25T10:00:00Z',
    'type': 'lecture',
    'deep_link': '/subjects/1/lectures',
  },
  {
    'id': 2,
    'title': 'Quiz Starting Soon',
    'content': 'Agile Basics Quiz starts in 30 minutes.',
    'created_at': '2023-10-25T11:30:00Z',
    'type': 'quiz',
    'deep_link': '/subjects/1/quizzes',
  },
];

final List<Map<String, dynamic>> mockPostsData = [
  {
    'id': 1,
    'text': 'Does anyone have the notes for yesterday\'s Software Engineering lecture?',
    'author_name': 'Dr. Sarah Smith',
    'likes': 5,
    'reactions': ['👍', '❤️'],
    'comments_count': 2,
    'created_at': '2023-10-24T15:00:00Z',
    'comments': [
      {
        'id': 1,
        'student_name': 'Ali Mohamed',
        'created_at': '2023-10-24T15:30:00Z',
        'text': 'I have them! I will upload them to summaries.',
      },
      {
        'id': 2,
        'student_name': 'Sara Hassan',
        'created_at': '2023-10-24T16:00:00Z',
        'text': 'Thanks Ali!',
      },
    ],
  },
];

final List<Map<String, dynamic>> mockSubmissionsData = [];
final List<Map<String, dynamic>> mockCommentsData = [];
final List<Map<String, dynamic>> mockCalendarEventsData = [];
