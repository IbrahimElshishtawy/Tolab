import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/quiz_models.dart';
import '../../../../core/services/mock_backend_service.dart';
import '../../domain/repositories/quizzes_repository.dart';

final quizzesRepositoryProvider = Provider<QuizzesRepository>((ref) {
  return MockQuizzesRepository(ref.watch(mockBackendServiceProvider));
});

class MockQuizzesRepository implements QuizzesRepository {
  const MockQuizzesRepository(this._backendService);

  final MockBackendService _backendService;

  @override
  Future<List<QuizItem>> fetchQuizzes({String? subjectId}) {
    return _backendService.fetchQuizzes(subjectId: subjectId);
  }

  @override
  Future<StudentQuizDetails> fetchQuizDetails({
    required String subjectId,
    required String quizId,
  }) async {
    final quizzes = await _backendService.fetchQuizzes(subjectId: subjectId);
    final quiz = quizzes.firstWhere((item) => item.id == quizId);

    final questions = _questionBank[quizId] ?? _defaultQuestions;
    return StudentQuizDetails(
      quiz: quiz.copyWith(
        questionCount: quiz.questionCount ?? questions.length,
        durationMinutes: quiz.durationMinutes ?? _durationForQuiz(quizId),
      ),
      overview: _overviewForQuiz(quiz),
      rules: _rulesForQuiz(quiz),
      questions: questions,
      availableStatusLabel: _statusForQuiz(quiz),
      attemptsLabel: 'المحاولات ${quiz.attemptsUsed}/${quiz.maxAttempts}',
    );
  }

  @override
  Future<QuizItem> submitQuiz(String quizId, {String? subjectId}) async {
    await _backendService.submitQuiz(quizId);
    final quizzes = await _backendService.fetchQuizzes(subjectId: subjectId);
    return quizzes.firstWhere((quiz) => quiz.id == quizId);
  }
}

String _overviewForQuiz(QuizItem quiz) {
  if (quiz.subjectName != null) {
    return 'تجربة تقييم مرنة داخل ${quiz.subjectName} مع واجهة مناسبة للموبايل والديسكتوب.';
  }
  return 'هذا الكويز مصمم لتقييم الفهم التطبيقي والسرعة في الإجابة.';
}

List<String> _rulesForQuiz(QuizItem quiz) {
  return [
    'يجب التأكد من ثبات الاتصال قبل بدء الكويز.',
    'يمكنك التنقل بين الأسئلة قبل الإرسال النهائي.',
    'يظهر المؤقت أعلى الشاشة ويتم الحفظ داخل الجلسة الحالية.',
    if (quiz.maxAttempts > 1) 'عدد المحاولات المتاحة: ${quiz.maxAttempts}.',
    if (quiz.reviewAllowed)
      'تظهر المراجعة بعد التسليم إذا كانت متاحة من المدرس.',
  ];
}

String _statusForQuiz(QuizItem quiz) {
  final now = DateTime.now();
  if (quiz.isSubmitted) {
    return 'تم التسليم';
  }
  if (quiz.startsAt != null &&
      quiz.closesAt != null &&
      !quiz.startsAt!.isAfter(now) &&
      quiz.closesAt!.isAfter(now)) {
    return 'متاح الآن';
  }
  if (quiz.startsAt != null && quiz.startsAt!.isAfter(now)) {
    return 'سيبدأ لاحقًا';
  }
  return 'مغلق';
}

int _durationForQuiz(String quizId) {
  switch (quizId) {
    case 'quiz-1':
      return 20;
    case 'quiz-2':
      return 30;
    case 'quiz-3':
      return 15;
    default:
      return 20;
  }
}

const _defaultQuestions = <QuizQuestion>[
  QuizQuestion(
    id: 'question-default-1',
    title: 'ما الهدف الأساسي من هذه المحاولة؟',
    type: QuizQuestionType.shortAnswer,
    points: 5,
  ),
];

const _questionBank = <String, List<QuizQuestion>>{
  'quiz-1': [
    QuizQuestion(
      id: 'quiz-1-q1',
      title: 'أي أداة تُستخدم غالبًا لإدارة الحالة في هذا المشروع؟',
      type: QuizQuestionType.mcq,
      points: 2,
      options: [
        QuizOption(id: 'a', label: 'Riverpod'),
        QuizOption(id: 'b', label: 'Bloc'),
        QuizOption(id: 'c', label: 'Redux'),
      ],
    ),
    QuizQuestion(
      id: 'quiz-1-q2',
      title: 'تصميم Adaptive مهم لتجنب overflow على الشاشات الصغيرة.',
      type: QuizQuestionType.trueFalse,
      points: 1,
      options: [
        QuizOption(id: 'true', label: 'صح'),
        QuizOption(id: 'false', label: 'خطأ'),
      ],
    ),
    QuizQuestion(
      id: 'quiz-1-q3',
      title: 'اختر العناصر التي يجب مراقبتها في واجهة الطالب.',
      type: QuizQuestionType.checkbox,
      points: 3,
      options: [
        QuizOption(id: 'overflow', label: 'الـ overflow'),
        QuizOption(id: 'spacing', label: 'المسافات'),
        QuizOption(id: 'responsiveness', label: 'الاستجابة للشاشات'),
        QuizOption(id: 'random', label: 'ألوان عشوائية'),
      ],
    ),
    QuizQuestion(
      id: 'quiz-1-q4',
      title: 'اذكر مكونًا واحدًا يساعد على بناء layout responsive في Flutter.',
      type: QuizQuestionType.shortAnswer,
      points: 4,
    ),
  ],
  'quiz-2': [
    QuizQuestion(
      id: 'quiz-2-q1',
      title: 'أي مفهوم يوزع الحمل تلقائيًا في البيئات السحابية؟',
      type: QuizQuestionType.mcq,
      points: 2,
      options: [
        QuizOption(id: 'a', label: 'Auto Scaling'),
        QuizOption(id: 'b', label: 'Hard Coding'),
        QuizOption(id: 'c', label: 'Local Cache Only'),
      ],
    ),
    QuizQuestion(
      id: 'quiz-2-q2',
      title: 'Kubernetes يساعد على إدارة الحاويات في بيئات الإنتاج.',
      type: QuizQuestionType.trueFalse,
      points: 1,
      options: [
        QuizOption(id: 'true', label: 'صح'),
        QuizOption(id: 'false', label: 'خطأ'),
      ],
    ),
    QuizQuestion(
      id: 'quiz-2-q3',
      title: 'اختر مزايا الحوسبة السحابية.',
      type: QuizQuestionType.checkbox,
      points: 3,
      options: [
        QuizOption(id: 'elastic', label: 'المرونة'),
        QuizOption(id: 'scalable', label: 'القابلية للتوسع'),
        QuizOption(id: 'downtime', label: 'تعطل دائم'),
        QuizOption(id: 'distributed', label: 'التوزيع'),
      ],
    ),
    QuizQuestion(
      id: 'quiz-2-q4',
      title: 'اشرح باختصار معنى high availability.',
      type: QuizQuestionType.shortAnswer,
      points: 4,
    ),
  ],
  'quiz-3': [
    QuizQuestion(
      id: 'quiz-3-q1',
      title: 'أي هدف أساسي من أهداف UX؟',
      type: QuizQuestionType.mcq,
      points: 2,
      options: [
        QuizOption(id: 'a', label: 'تسهيل الاستخدام'),
        QuizOption(id: 'b', label: 'زيادة التعقيد'),
        QuizOption(id: 'c', label: 'إخفاء المحتوى'),
      ],
    ),
    QuizQuestion(
      id: 'quiz-3-q2',
      title: 'واجهة الموبايل يجب أن تعتمد على مساحات لمس مناسبة.',
      type: QuizQuestionType.trueFalse,
      points: 1,
      options: [
        QuizOption(id: 'true', label: 'صح'),
        QuizOption(id: 'false', label: 'خطأ'),
      ],
    ),
    QuizQuestion(
      id: 'quiz-3-q3',
      title: 'اختر عناصر تقييم واجهة المستخدم.',
      type: QuizQuestionType.checkbox,
      points: 3,
      options: [
        QuizOption(id: 'contrast', label: 'التباين'),
        QuizOption(id: 'hierarchy', label: 'الهرمية البصرية'),
        QuizOption(id: 'overflow', label: 'سلامة التخطيط'),
        QuizOption(id: 'noise', label: 'التشويش المقصود'),
      ],
    ),
    QuizQuestion(
      id: 'quiz-3-q4',
      title: 'اذكر مثالًا واحدًا لتحسين إمكانية الوصول.',
      type: QuizQuestionType.shortAnswer,
      points: 4,
    ),
  ],
};
