class SubjectTabs {
  static const items = <(String, String)>[
    ('lectures', 'المحاضرات'),
    ('sections', 'السكاشن'),
    ('quizzes', 'الكويزات'),
    ('tasks', 'الشيتات'),
    ('summaries', 'الملخصات'),
    ('files', 'الملفات'),
    ('group', 'الجروب'),
    ('grades', 'الدرجات'),
  ];

  static int indexFor(String? key) {
    final index = items.indexWhere((tab) => tab.$1 == key);
    return index < 0 ? 0 : index;
  }
}
