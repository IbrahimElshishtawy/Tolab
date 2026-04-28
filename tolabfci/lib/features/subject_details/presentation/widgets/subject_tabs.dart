class SubjectTabs {
  static const items = <(String, String)>[
    ('overview', 'Overview'),
    ('lectures', 'المحاضرات'),
    ('sections', 'السكاشن'),
    ('quizzes', 'الكويزات'),
    ('tasks', 'الشيتات'),
    ('summaries', 'الملخصات'),
    ('grades', 'الدرجات'),
    ('community', 'Community'),
    ('chat', 'Group Chat'),
  ];

  static int indexFor(String? key) {
    final index = items.indexWhere((tab) => tab.$1 == key);
    return index < 0 ? 0 : index;
  }
}
