import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../mock/mock_portal_models.dart';
import '../../../../models/doctor_assistant_models.dart';

class QuizzesWorkspaceData {
  const QuizzesWorkspaceData({
    required this.metrics,
    required this.quickActions,
    required this.quizzes,
    required this.openNow,
    required this.drafts,
    required this.startingToday,
    required this.recentActivity,
    required this.quickInsights,
    required this.healthLabel,
    required this.healthTone,
    required this.healthSummary,
  });

  final List<WorkspaceOverviewMetric> metrics;
  final List<WorkspaceQuickAction> quickActions;
  final List<QuizWorkspaceItem> quizzes;
  final List<QuizWorkspaceItem> openNow;
  final List<QuizWorkspaceItem> drafts;
  final List<QuizWorkspaceItem> startingToday;
  final List<QuizWorkspaceActivity> recentActivity;
  final List<String> quickInsights;
  final String healthLabel;
  final String healthTone;
  final String healthSummary;
}

class QuizWorkspaceItem {
  const QuizWorkspaceItem({
    required this.id,
    required this.subjectId,
    required this.subjectLabel,
    required this.subjectCode,
    required this.title,
    required this.description,
    required this.statusLabel,
    required this.statusTone,
    required this.startAt,
    required this.endAt,
    required this.durationMinutes,
    required this.questionCount,
    required this.totalMarks,
    required this.totalStudents,
    required this.enteredStudents,
    required this.completedStudents,
    required this.averageScore,
    required this.passRate,
    required this.attemptsAllowed,
    required this.audienceLabel,
    required this.accentColor,
    required this.liveParticipants,
    required this.questions,
    required this.submissions,
    this.attachmentName,
  });

  final int id;
  final int subjectId;
  final String subjectLabel;
  final String subjectCode;
  final String title;
  final String description;
  final String statusLabel;
  final String statusTone;
  final DateTime startAt;
  final DateTime endAt;
  final int durationMinutes;
  final int questionCount;
  final int totalMarks;
  final int totalStudents;
  final int enteredStudents;
  final int completedStudents;
  final double averageScore;
  final double passRate;
  final int attemptsAllowed;
  final String audienceLabel;
  final Color accentColor;
  final int liveParticipants;
  final List<QuizWorkspaceQuestion> questions;
  final List<QuizWorkspaceSubmission> submissions;
  final String? attachmentName;

  int get notStartedStudents => max(0, totalStudents - enteredStudents);
  double get completionRatio =>
      totalStudents == 0 ? 0 : completedStudents / totalStudents;
  bool get isDraft => statusLabel == 'Draft';
  bool get isOpen => statusLabel == 'Open';
  bool get isScheduled => statusLabel == 'Scheduled';
  bool get isClosed => statusLabel == 'Closed';
  bool get startsToday => _sameDay(startAt, _workspaceNow);
  String get startLabel => DateFormat('EEE, d MMM - h:mm a').format(startAt);
  String get endLabel => DateFormat('EEE, d MMM - h:mm a').format(endAt);
  String get durationLabel => '$durationMinutes min';
  String get timeRemainingLabel {
    if (!isOpen) {
      return endAt.isBefore(_workspaceNow)
          ? 'Closed ${_relativeTime(endAt)}'
          : 'Starts ${DateFormat('h:mm a').format(startAt)}';
    }
    final remaining = endAt.difference(_workspaceNow);
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60);
    return '${hours}h ${minutes.toString().padLeft(2, '0')}m left';
  }
}

class QuizWorkspaceQuestion {
  const QuizWorkspaceQuestion({
    required this.id,
    required this.prompt,
    required this.type,
    required this.options,
    required this.correctAnswers,
    required this.marks,
    required this.isRequired,
  });

  final String id;
  final String prompt;
  final String type;
  final List<String> options;
  final List<String> correctAnswers;
  final int marks;
  final bool isRequired;
}

class QuizWorkspaceSubmission {
  const QuizWorkspaceSubmission({
    required this.studentName,
    required this.studentCode,
    required this.statusLabel,
    required this.progress,
    this.score,
    this.startedAt,
    this.submittedAt,
  });

  final String studentName;
  final String studentCode;
  final String statusLabel;
  final double progress;
  final double? score;
  final DateTime? startedAt;
  final DateTime? submittedAt;
}

class QuizWorkspaceActivity {
  const QuizWorkspaceActivity({
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    required this.tone,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String timeLabel;
  final String tone;
  final IconData icon;
}

class QuizGradeBucket {
  const QuizGradeBucket({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;
}

class QuizTimelinePoint {
  const QuizTimelinePoint({required this.label, required this.value});

  final String label;
  final double value;
}

QuizzesWorkspaceData buildQuizzesWorkspaceData({
  required List<TeachingSubject> subjects,
  required List<MockStudentResult> results,
  required List<MockStudentDirectoryEntry> students,
  required List<WorkspaceNotificationItem> notifications,
  required List<MockAnnouncementItem> announcements,
}) {
  final quizzes = <QuizWorkspaceItem>[];
  for (final subject in subjects) {
    for (var index = 0; index < subject.quizzes.length; index++) {
      quizzes.add(
        _buildQuizWorkspaceItem(
          subject: subject,
          quiz: subject.quizzes[index],
          results: results,
          students: students,
          index: index,
        ),
      );
    }
  }

  quizzes.sort((left, right) => left.startAt.compareTo(right.startAt));
  final openNow = quizzes.where((quiz) => quiz.isOpen).toList(growable: false);
  final drafts = quizzes.where((quiz) => quiz.isDraft).toList(growable: false);
  final startingToday = quizzes
      .where((quiz) => quiz.startsToday && !quiz.isClosed)
      .toList(growable: false);
  final publishedCount = quizzes.where((quiz) => !quiz.isDraft).length;
  final scheduledCount = quizzes.where((quiz) => quiz.isScheduled).length;
  final averageCompletion = quizzes.isEmpty
      ? 0.0
      : quizzes.fold<double>(0, (sum, quiz) => sum + quiz.completionRatio) /
            quizzes.length;
  final averagePassRate = quizzes.isEmpty
      ? 0.0
      : quizzes.fold<double>(0, (sum, quiz) => sum + quiz.passRate) /
            quizzes.length;
  final recentActivity = _buildRecentActivity(
    quizzes: quizzes,
    notifications: notifications,
    announcements: announcements,
    results: results,
  );
  final quickInsights = <String>[
    if (openNow.isNotEmpty)
      '${openNow.length} quiz${openNow.length == 1 ? '' : 'zes'} are live now with ${openNow.fold<int>(0, (sum, item) => sum + item.liveParticipants)} students inside.',
    if (drafts.isNotEmpty)
      '${drafts.length} quiz draft${drafts.length == 1 ? '' : 's'} still need publishing review.',
    ...quizzes
        .where((quiz) => quiz.passRate < 65)
        .map(
          (quiz) =>
              '${quiz.title} shows a low pass rate at ${quiz.passRate.toStringAsFixed(0)}%.',
        )
        .take(1),
    ...quizzes
        .where(
          (quiz) => quiz.notStartedStudents > max(8, quiz.totalStudents ~/ 4),
        )
        .map(
          (quiz) =>
              '${quiz.notStartedStudents} students have not started ${quiz.title} yet.',
        )
        .take(1),
  ].take(4).toList(growable: false);

  final healthTone =
      openNow.any((quiz) => quiz.notStartedStudents > quiz.totalStudents ~/ 3)
      ? 'danger'
      : quickInsights.any((item) => item.contains('low pass rate')) ||
            drafts.isNotEmpty
      ? 'warning'
      : 'success';
  final healthLabel = switch (healthTone) {
    'danger' => 'Live Monitoring',
    'warning' => 'Needs Review',
    _ => 'Healthy Queue',
  };

  return QuizzesWorkspaceData(
    metrics: [
      WorkspaceOverviewMetric(
        label: 'Published quizzes',
        value: '$publishedCount',
        caption: 'Draft-free quizzes already in the academic flow',
        icon: Icons.publish_rounded,
        color: const Color(0xFF2563EB),
      ),
      WorkspaceOverviewMetric(
        label: 'Draft quizzes',
        value: '${drafts.length}',
        caption: 'Assessments still under builder review',
        icon: Icons.edit_note_rounded,
        color: const Color(0xFFF59E0B),
      ),
      WorkspaceOverviewMetric(
        label: 'Open now',
        value: '${openNow.length}',
        caption: 'Currently live quiz windows requiring monitoring',
        icon: Icons.bolt_rounded,
        color: const Color(0xFFF43F5E),
      ),
      WorkspaceOverviewMetric(
        label: 'Scheduled',
        value: '$scheduledCount',
        caption: 'Quiz windows queued for later release',
        icon: Icons.event_rounded,
        color: const Color(0xFF14B8A6),
      ),
      WorkspaceOverviewMetric(
        label: 'Average completion',
        value: '${(averageCompletion * 100).round()}%',
        caption: 'Completion progress across the current quiz set',
        icon: Icons.donut_large_rounded,
        color: const Color(0xFF7C3AED),
      ),
      WorkspaceOverviewMetric(
        label: 'Average pass rate',
        value: '${averagePassRate.round()}%',
        caption: 'Learner success trend across active assessments',
        icon: Icons.workspace_premium_rounded,
        color: const Color(0xFF0EA5E9),
      ),
    ],
    quickActions: const [
      WorkspaceQuickAction(
        title: 'Open results',
        subtitle: 'Review scores and grading analytics',
        route: '/workspace/results',
        icon: Icons.insights_rounded,
      ),
      WorkspaceQuickAction(
        title: 'View students',
        subtitle: 'Track who still has not started',
        route: '/workspace/students',
        icon: Icons.groups_rounded,
      ),
      WorkspaceQuickAction(
        title: 'Open schedule',
        subtitle: 'Check quiz windows against lectures and sections',
        route: '/workspace/schedule',
        icon: Icons.schedule_rounded,
      ),
      WorkspaceQuickAction(
        title: 'Send announcement',
        subtitle: 'Broadcast reminders before the quiz opens',
        route: '/workspace/announcements',
        icon: Icons.campaign_rounded,
      ),
    ],
    quizzes: quizzes,
    openNow: openNow,
    drafts: drafts,
    startingToday: startingToday,
    recentActivity: recentActivity,
    quickInsights: quickInsights,
    healthLabel: healthLabel,
    healthTone: healthTone,
    healthSummary: openNow.isEmpty
        ? 'No live incidents right now. Draft, scheduled, and closed quizzes are all visible from one monitoring board.'
        : '${openNow.length} live quiz window${openNow.length == 1 ? '' : 's'} still need close monitoring for completion and progress.',
  );
}

QuizWorkspaceItem _buildQuizWorkspaceItem({
  required TeachingSubject subject,
  required TeachingQuiz quiz,
  required List<MockStudentResult> results,
  required List<MockStudentDirectoryEntry> students,
  required int index,
}) {
  final startAt = _resolveQuizStartAt(quiz, index);
  final durationMinutes =
      quiz.durationMinutes ?? _durationFromWindow(quiz.windowLabel) ?? 30;
  final endAt =
      DateTime.tryParse(quiz.endAtIso ?? '') ??
      startAt.add(Duration(minutes: durationMinutes));
  final statusLabel = _quizStatusLabel(quiz.statusLabel, startAt, endAt);
  final audienceLabel = quiz.audienceLabel ?? quiz.scopeLabel;
  final questionSeed = quiz.questions.isEmpty
      ? _defaultQuestionsForQuiz(subject: subject, quiz: quiz)
      : quiz.questions
            .map(
              (question) => QuizWorkspaceQuestion(
                id: question.id,
                prompt: question.prompt,
                type: question.type,
                options: question.options,
                correctAnswers: question.correctAnswers,
                marks: question.marks,
                isRequired: question.isRequired,
              ),
            )
            .toList(growable: false);
  final relevantStudents = students
      .where((student) => student.subjectCode == subject.code)
      .toList(growable: false);
  final totalStudents =
      quiz.totalStudents ?? max(subject.studentCount, relevantStudents.length);
  final enteredStudents =
      (quiz.enteredStudents ??
              _parseAttemptEntry(quiz.attemptsLabel)?.$1 ??
              ((totalStudents * (statusLabel == 'Draft' ? 0 : 0.58)).round()))
          .clamp(0, totalStudents);
  final completedStudents =
      (quiz.completedStudents ??
              _parseAttemptEntry(quiz.attemptsLabel)?.$1 ??
              ((enteredStudents * (statusLabel == 'Open' ? 0.62 : 0.82))
                  .round()))
          .clamp(0, enteredStudents);
  final quizResults = results
      .where(
        (result) =>
            result.subjectCode == subject.code &&
            result.assessmentTitle.toLowerCase() == quiz.title.toLowerCase(),
      )
      .toList(growable: false);
  final submissions = quiz.submissions.isEmpty
      ? _buildGeneratedSubmissions(
          quizResults: quizResults,
          relevantStudents: relevantStudents,
          totalStudents: totalStudents,
          enteredStudents: enteredStudents,
          completedStudents: completedStudents,
          totalMarks:
              quiz.totalMarks ??
              questionSeed.fold<int>(0, (sum, item) => sum + item.marks),
          statusLabel: statusLabel,
        )
      : quiz.submissions
            .map(
              (submission) => QuizWorkspaceSubmission(
                studentName: submission.studentName,
                studentCode: submission.studentCode,
                statusLabel: submission.statusLabel,
                progress: submission.progress,
                score: submission.score,
                startedAt: DateTime.tryParse(submission.startedAtIso ?? ''),
                submittedAt: DateTime.tryParse(submission.submittedAtIso ?? ''),
              ),
            )
            .toList(growable: false);
  final completed = submissions
      .where((submission) => submission.statusLabel == 'Completed')
      .toList(growable: false);
  final totalMarks =
      quiz.totalMarks ??
      questionSeed.fold<int>(0, (sum, item) => sum + item.marks);
  final averageScore =
      quiz.averageScore ??
      (completed.isEmpty
          ? 0
          : completed
                    .where((submission) => submission.score != null)
                    .fold<double>(
                      0,
                      (sum, submission) => sum + submission.score!,
                    ) /
                completed.length /
                max(1, totalMarks) *
                100);
  final passRate =
      quiz.passRate ??
      (completed.isEmpty
          ? 0
          : completed
                    .where(
                      (submission) =>
                          (submission.score ?? 0) >= totalMarks * 0.5,
                    )
                    .length /
                completed.length *
                100);
  return QuizWorkspaceItem(
    id: _numericId(quiz.id),
    subjectId: subject.id,
    subjectLabel: '${subject.code} - ${subject.name}',
    subjectCode: subject.code,
    title: quiz.title,
    description:
        quiz.description ??
        'Use the builder to refine the quiz window, question structure, and student communication before release.',
    statusLabel: statusLabel,
    statusTone: _toneForStatus(statusLabel),
    startAt: startAt,
    endAt: endAt,
    durationMinutes: durationMinutes,
    questionCount: quiz.questionCount ?? questionSeed.length,
    totalMarks: totalMarks,
    totalStudents: totalStudents,
    enteredStudents: enteredStudents,
    completedStudents: completedStudents,
    averageScore: averageScore,
    passRate: passRate,
    attemptsAllowed: quiz.attemptsAllowed ?? 1,
    audienceLabel: audienceLabel,
    accentColor: subject.accentColor,
    liveParticipants:
        quiz.liveParticipants ??
        max(
          0,
          submissions
              .where((submission) => submission.statusLabel == 'In Progress')
              .length,
        ),
    questions: questionSeed,
    submissions: submissions,
    attachmentName: quiz.attachmentName,
  );
}

DateTime _resolveQuizStartAt(TeachingQuiz quiz, int index) {
  final explicit = DateTime.tryParse(quiz.startAtIso ?? '');
  if (explicit != null) {
    return explicit;
  }
  final weekday =
      _weekdayNumber(
        quiz.windowLabel.substring(0, min(3, quiz.windowLabel.length)),
      ) ??
      ((_workspaceNow.weekday + index + 1) % 7) + 1;
  final timeMatch = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(quiz.windowLabel);
  final hour = int.tryParse(timeMatch?.group(1) ?? '') ?? 10;
  final minute = int.tryParse(timeMatch?.group(2) ?? '') ?? 0;
  var offset = weekday - _workspaceNow.weekday;
  if (quiz.statusLabel.toLowerCase() == 'scheduled' && offset < 0) {
    offset += 7;
  }
  if (quiz.statusLabel.toLowerCase() == 'draft') {
    offset = max(1, offset);
  }
  final baseDate = _workspaceNow.add(Duration(days: offset));
  return DateTime(baseDate.year, baseDate.month, baseDate.day, hour, minute);
}

String _quizStatusLabel(String rawStatus, DateTime startAt, DateTime endAt) {
  final normalized = rawStatus.toLowerCase();
  if (normalized.contains('draft')) {
    return 'Draft';
  }
  if (_workspaceNow.isBefore(startAt)) {
    return 'Scheduled';
  }
  if (_workspaceNow.isAfter(endAt)) {
    return 'Closed';
  }
  return 'Open';
}

String _toneForStatus(String statusLabel) {
  return switch (statusLabel) {
    'Open' => 'danger',
    'Draft' => 'warning',
    'Closed' => 'success',
    _ => 'primary',
  };
}

int? _durationFromWindow(String raw) {
  final minuteMatch = RegExp(
    r'(\d{1,3})\s*min',
    caseSensitive: false,
  ).firstMatch(raw);
  return int.tryParse(minuteMatch?.group(1) ?? '');
}

(int, int)? _parseAttemptEntry(String raw) {
  final match = RegExp(r'(\d+)\s*/\s*(\d+)').firstMatch(raw);
  final entered = int.tryParse(match?.group(1) ?? '');
  final total = int.tryParse(match?.group(2) ?? '');
  if (entered == null || total == null) {
    return null;
  }
  return (entered, total);
}

List<QuizWorkspaceQuestion> _defaultQuestionsForQuiz({
  required TeachingSubject subject,
  required TeachingQuiz quiz,
}) {
  final prompts = <QuizWorkspaceQuestion>[
    QuizWorkspaceQuestion(
      id: '${quiz.id}-q1',
      prompt: 'Which learning objective is most central to ${quiz.title}?',
      type: 'multiple_choice',
      options: [
        'Apply the key concept in a new scenario',
        'Recall definitions only',
        'Memorize the lecture slides',
        'Skip reasoning and estimate answers',
      ],
      correctAnswers: const ['Apply the key concept in a new scenario'],
      marks: 2,
      isRequired: true,
    ),
    QuizWorkspaceQuestion(
      id: '${quiz.id}-q2',
      prompt: '${subject.name} requires both accuracy and explanation.',
      type: 'true_false',
      options: const ['True', 'False'],
      correctAnswers: const ['True'],
      marks: 1,
      isRequired: true,
    ),
    QuizWorkspaceQuestion(
      id: '${quiz.id}-q3',
      prompt:
          'List one practical scenario where this topic appears in the course workflow.',
      type: 'short_answer',
      options: const [],
      correctAnswers: const ['Any valid scenario tied to the topic'],
      marks: 3,
      isRequired: true,
    ),
    QuizWorkspaceQuestion(
      id: '${quiz.id}-q4',
      prompt: 'Which checkpoints should students complete before submission?',
      type: 'checkbox',
      options: const [
        'Review the worked example',
        'Check time limit',
        'Submit without validation',
        'Verify final answer',
      ],
      correctAnswers: const [
        'Review the worked example',
        'Check time limit',
        'Verify final answer',
      ],
      marks: 4,
      isRequired: false,
    ),
  ];
  return prompts;
}

List<QuizWorkspaceSubmission> _buildGeneratedSubmissions({
  required List<MockStudentResult> quizResults,
  required List<MockStudentDirectoryEntry> relevantStudents,
  required int totalStudents,
  required int enteredStudents,
  required int completedStudents,
  required int totalMarks,
  required String statusLabel,
}) {
  final generated = <QuizWorkspaceSubmission>[];
  for (final result in quizResults) {
    generated.add(
      QuizWorkspaceSubmission(
        studentName: result.studentName,
        studentCode: result.studentCode,
        statusLabel: 'Completed',
        progress: 1,
        score: result.score,
        submittedAt: result.updatedAt,
      ),
    );
  }

  var remainingCompleted = max(0, completedStudents - generated.length);
  for (var index = 0; index < remainingCompleted; index++) {
    final student = index < relevantStudents.length
        ? relevantStudents[index]
        : MockStudentDirectoryEntry(
            id: 'generated-$index',
            name: 'Student ${index + 1}',
            code: '20260${(index + 1).toString().padLeft(3, '0')}',
            email: '',
            subjectCode: '',
            sectionLabel: '',
            attendanceRate: 0,
            averageScore: 0,
            engagementScore: 0,
            riskLabel: 'Stable',
            lastActiveAt: _workspaceNow,
          );
    generated.add(
      QuizWorkspaceSubmission(
        studentName: student.name,
        studentCode: student.code,
        statusLabel: 'Completed',
        progress: 1,
        score: (totalMarks * (0.52 + ((index % 5) * 0.08)))
            .clamp(0, totalMarks)
            .toDouble(),
        submittedAt: _workspaceNow.subtract(
          Duration(minutes: 12 + (index * 5)),
        ),
      ),
    );
  }

  final liveOrInProgress = max(0, enteredStudents - completedStudents);
  for (var index = 0; index < liveOrInProgress; index++) {
    final rosterIndex = completedStudents + index;
    final student = rosterIndex < relevantStudents.length
        ? relevantStudents[rosterIndex]
        : MockStudentDirectoryEntry(
            id: 'live-$index',
            name: 'Student ${rosterIndex + 1}',
            code: '20261${(rosterIndex + 1).toString().padLeft(3, '0')}',
            email: '',
            subjectCode: '',
            sectionLabel: '',
            attendanceRate: 0,
            averageScore: 0,
            engagementScore: 0,
            riskLabel: 'Stable',
            lastActiveAt: _workspaceNow,
          );
    generated.add(
      QuizWorkspaceSubmission(
        studentName: student.name,
        studentCode: student.code,
        statusLabel: statusLabel == 'Open' ? 'In Progress' : 'Completed',
        progress: statusLabel == 'Open' ? 0.35 + ((index % 4) * 0.14) : 1,
        score: statusLabel == 'Open' ? null : (totalMarks * 0.64).toDouble(),
        startedAt: _workspaceNow.subtract(Duration(minutes: 5 + (index * 3))),
      ),
    );
  }

  final remainingNotStarted = max(0, totalStudents - enteredStudents);
  for (var index = 0; index < remainingNotStarted; index++) {
    final rosterIndex = enteredStudents + index;
    final student = rosterIndex < relevantStudents.length
        ? relevantStudents[rosterIndex]
        : MockStudentDirectoryEntry(
            id: 'ns-$index',
            name: 'Student ${rosterIndex + 1}',
            code: '20262${(rosterIndex + 1).toString().padLeft(3, '0')}',
            email: '',
            subjectCode: '',
            sectionLabel: '',
            attendanceRate: 0,
            averageScore: 0,
            engagementScore: 0,
            riskLabel: 'Stable',
            lastActiveAt: _workspaceNow,
          );
    generated.add(
      QuizWorkspaceSubmission(
        studentName: student.name,
        studentCode: student.code,
        statusLabel: 'Not Started',
        progress: 0,
      ),
    );
  }

  return generated;
}

List<QuizWorkspaceActivity> _buildRecentActivity({
  required List<QuizWorkspaceItem> quizzes,
  required List<WorkspaceNotificationItem> notifications,
  required List<MockAnnouncementItem> announcements,
  required List<MockStudentResult> results,
}) {
  final items = <MapEntry<DateTime, QuizWorkspaceActivity>>[];
  for (final quiz in quizzes.take(3)) {
    items.add(
      MapEntry(
        quiz.startAt.subtract(const Duration(hours: 5)),
        QuizWorkspaceActivity(
          title: '${quiz.title} status changed to ${quiz.statusLabel}',
          subtitle: '${quiz.subjectCode} - ${quiz.questionCount} questions',
          timeLabel: _relativeTime(
            quiz.startAt.subtract(const Duration(hours: 5)),
          ),
          tone: quiz.statusTone,
          icon: quiz.isOpen ? Icons.bolt_rounded : Icons.quiz_rounded,
        ),
      ),
    );
  }

  for (final notification in notifications.take(3)) {
    items.add(
      MapEntry(
        _workspaceNow.subtract(const Duration(minutes: 30)),
        QuizWorkspaceActivity(
          title: notification.title,
          subtitle: notification.body,
          timeLabel: notification.timeLabel,
          tone: notification.isRead ? 'primary' : 'warning',
          icon: notification.icon,
        ),
      ),
    );
  }

  for (final announcement in announcements.take(2)) {
    items.add(
      MapEntry(
        announcement.publishedAt,
        QuizWorkspaceActivity(
          title: announcement.title,
          subtitle:
              '${announcement.subjectCode} - ${announcement.audienceLabel}',
          timeLabel: _relativeTime(announcement.publishedAt),
          tone: announcement.priorityLabel.toLowerCase() == 'urgent'
              ? 'danger'
              : 'primary',
          icon: Icons.campaign_rounded,
        ),
      ),
    );
  }

  for (final result in results.take(2)) {
    items.add(
      MapEntry(
        result.updatedAt,
        QuizWorkspaceActivity(
          title: '${result.studentName} submitted ${result.assessmentTitle}',
          subtitle:
              '${result.subjectCode} - ${result.score.toStringAsFixed(0)}/${result.maxScore.toStringAsFixed(0)}',
          timeLabel: _relativeTime(result.updatedAt),
          tone: result.percentage < 50 ? 'warning' : 'success',
          icon: Icons.grading_rounded,
        ),
      ),
    );
  }

  items.sort((left, right) => right.key.compareTo(left.key));
  return items.map((item) => item.value).take(6).toList(growable: false);
}

List<QuizGradeBucket> buildQuizGradeBuckets(QuizWorkspaceItem quiz) {
  final buckets = <String, int>{
    '0-49': 0,
    '50-59': 0,
    '60-69': 0,
    '70-79': 0,
    '80-100': 0,
  };
  for (final submission in quiz.submissions.where(
    (submission) => submission.score != null,
  )) {
    final percentage = submission.score! / max(1, quiz.totalMarks) * 100;
    if (percentage < 50) {
      buckets['0-49'] = buckets['0-49']! + 1;
    } else if (percentage < 60) {
      buckets['50-59'] = buckets['50-59']! + 1;
    } else if (percentage < 70) {
      buckets['60-69'] = buckets['60-69']! + 1;
    } else if (percentage < 80) {
      buckets['70-79'] = buckets['70-79']! + 1;
    } else {
      buckets['80-100'] = buckets['80-100']! + 1;
    }
  }
  final colors = <Color>[
    const Color(0xFFF43F5E),
    const Color(0xFFF97316),
    const Color(0xFFF59E0B),
    const Color(0xFF14B8A6),
    const Color(0xFF2563EB),
  ];
  final labels = buckets.keys.toList(growable: false);
  return List<QuizGradeBucket>.generate(labels.length, (index) {
    final label = labels[index];
    return QuizGradeBucket(
      label: label,
      count: buckets[label]!,
      color: colors[index],
    );
  });
}

List<QuizTimelinePoint> buildQuizSubmissionTrend(QuizWorkspaceItem quiz) {
  final completed =
      quiz.submissions
          .where((submission) => submission.submittedAt != null)
          .toList(growable: false)
        ..sort(
          (left, right) => left.submittedAt!.compareTo(right.submittedAt!),
        );
  if (completed.isEmpty) {
    return const <QuizTimelinePoint>[];
  }
  var running = 0;
  return completed
      .take(5)
      .map((submission) {
        running += 1;
        return QuizTimelinePoint(
          label: DateFormat('h:mm a').format(submission.submittedAt!),
          value: running.toDouble(),
        );
      })
      .toList(growable: false);
}

int _numericId(String raw) {
  final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
  return int.tryParse(digits) ?? raw.hashCode.abs();
}

int? _weekdayNumber(String raw) {
  return switch (raw.toLowerCase()) {
    'mon' => DateTime.monday,
    'tue' => DateTime.tuesday,
    'wed' => DateTime.wednesday,
    'thu' => DateTime.thursday,
    'fri' => DateTime.friday,
    'sat' => DateTime.saturday,
    'sun' => DateTime.sunday,
    _ => null,
  };
}

bool _sameDay(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}

String _relativeTime(DateTime value) {
  final difference = _workspaceNow.difference(value);
  if (difference.inMinutes < 60) {
    return '${difference.inMinutes} min ago';
  }
  if (difference.inHours < 24) {
    return '${difference.inHours} hr ago';
  }
  return '${difference.inDays} day ago';
}

final DateTime _workspaceNow = DateTime(2026, 4, 23, 12);
