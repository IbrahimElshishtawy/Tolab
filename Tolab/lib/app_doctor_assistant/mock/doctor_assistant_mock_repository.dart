import 'dart:math';

import 'package:flutter/material.dart';

import '../../app_admin/core/colors/app_colors.dart';
import '../../app_admin/modules/schedule/models/schedule_models.dart';
import '../core/models/academic_models.dart';
import '../core/models/content_models.dart';
import '../core/models/dashboard_models.dart';
import '../core/models/notification_models.dart';
import '../core/models/session_user.dart';
import '../core/models/staff_models.dart';
import '../core/navigation/app_routes.dart';
import '../modules/groups/models/group_models.dart';
import '../modules/results/models/results_models.dart';
import '../modules/subjects/models/subject_workspace_models.dart';
import '../models/doctor_assistant_models.dart';
import 'mock_portal_models.dart';
import 'mock_sample_payloads.dart';

class DoctorAssistantMockRepository {
  DoctorAssistantMockRepository._() {
    _seed();
  }

  static final DoctorAssistantMockRepository instance =
      DoctorAssistantMockRepository._();

  final Map<String, _MockAccount> _accountsByEmail = {};
  final List<TeachingSubject> _subjects = [];
  final List<WorkspaceNotificationItem> _notifications = [];
  final List<ScheduleEventItem> _schedule = [];
  final List<UploadModel> _uploads = [];
  final List<MockStudentResult> _results = [];
  final List<MockAnnouncementItem> _announcements = [];
  final List<MockStudentDirectoryEntry> _students = [];
  final List<MockGroupPost> _groupPosts = [];
  final List<MockMessageThread> _messageThreads = [];
  final List<DepartmentModel> _departments = [];
  final Map<int, List<GroupPostModel>> _subjectPosts = {};
  final Map<int, Map<String, Map<String, _StoredGrade>>> _gradesBySubject = {};

  int _nextUploadId = 10;
  int _nextLectureId = 3000;
  int _nextSectionId = 4000;
  int _nextQuizId = 5000;
  int _nextTaskId = 6000;
  int _nextPostId = 7000;
  int _nextCommentId = 8000;

  Future<void> simulateLatency([
    Duration duration = const Duration(milliseconds: 280),
  ]) {
    return Future<void>.delayed(duration);
  }

  SessionUser authenticate({required String email, required String password}) {
    final account = _accountsByEmail[email.trim().toLowerCase()];
    if (account == null || account.password != password) {
      throw Exception('Invalid university email or password.');
    }

    if (!account.user.isActive) {
      throw Exception(
        'This account is inactive. Please contact administration.',
      );
    }

    return account.user;
  }

  SessionUser userByEmail(String email) {
    final account = _accountsByEmail[email.trim().toLowerCase()];
    if (account == null) {
      throw Exception('Mock account not found for $email.');
    }
    return account.user;
  }

  bool hasAccount(String email) {
    return _accountsByEmail.containsKey(email.trim().toLowerCase());
  }

  SessionUser? restoreUserFromSession(Map<String, dynamic>? session) {
    final rawUser = session?['user'];
    if (rawUser is Map<String, dynamic>) {
      return SessionUser.fromJson(rawUser);
    }
    if (rawUser is Map) {
      return SessionUser.fromJson(Map<String, dynamic>.from(rawUser));
    }
    return null;
  }

  SessionUser refreshUser(SessionUser user) {
    final account = _accountForUser(user);
    return account?.user ?? user;
  }

  SessionUser updateUserSettings(
    SessionUser user,
    Map<String, dynamic> payload,
  ) {
    final account = _accountForUser(user);
    if (account == null) {
      return user;
    }

    final nextUser = SessionUser(
      id: account.user.id,
      fullName: account.user.fullName,
      universityEmail: account.user.universityEmail,
      roleType: account.user.roleType,
      isActive: account.user.isActive,
      avatar: account.user.avatar,
      phone: payload['phone']?.toString() ?? account.user.phone,
      notificationEnabled:
          payload['notification_enabled'] as bool? ??
          account.user.notificationEnabled,
      language: payload['language']?.toString() ?? account.user.language,
      permissions: List<String>.from(account.user.permissions),
    );

    _accountsByEmail[account.user.universityEmail
        .toLowerCase()] = account.copyWith(
      user: nextUser,
      locationLabel:
          payload['location_label']?.toString() ?? account.locationLabel,
      officeHours: payload['office_hours']?.toString() ?? account.officeHours,
    );
    return nextUser;
  }

  List<TeachingSubject> subjectsFor(SessionUser user) =>
      List<TeachingSubject>.unmodifiable(_subjects);

  TeachingSubject subjectById(int subjectId) {
    return _subjects.firstWhere(
      (subject) => subject.id == subjectId,
      orElse: () => _subjects.first,
    );
  }

  TeachingSubject? subjectBySectionId(int sectionId) {
    for (final subject in _subjects) {
      if (subject.sections.any(
        (section) => _numericId(section.id) == sectionId,
      )) {
        return subject;
      }
    }
    return null;
  }

  TeachingSubject? subjectByQuizId(int quizId) {
    for (final subject in _subjects) {
      if (subject.quizzes.any((quiz) => _numericId(quiz.id) == quizId)) {
        return subject;
      }
    }
    return null;
  }

  TeachingSection? sectionById(int sectionId) {
    final subject = subjectBySectionId(sectionId);
    if (subject == null) {
      return null;
    }
    return subject.sections.firstWhere(
      (section) => _numericId(section.id) == sectionId,
    );
  }

  TeachingQuiz? quizById(int quizId) {
    final subject = subjectByQuizId(quizId);
    if (subject == null) {
      return null;
    }
    return subject.quizzes.firstWhere((quiz) => _numericId(quiz.id) == quizId);
  }

  List<SubjectModel> subjectModelsFor(SessionUser user) {
    _ensureGradebookSeeded();
    return _subjects
        .map(
          (subject) {
            final result = subjectResultsById(subject.id, user);
            final group = subjectGroupById(subject.id, user);
            final lastLecture = subject.lectures.isEmpty ? null : subject.lectures.first;
            final assistantName = subject.sections.isEmpty
                ? null
                : subject.sections.first.assistantName;
            return SubjectModel(
              id: subject.id,
              name: subject.name,
              code: subject.code,
              isActive: true,
              departmentName: subject.department,
              academicYearName: subject.academicTerm,
              description: subject.description,
              doctorName: _ownerNameForSubject(subject.id),
              assistantName: assistantName,
              studentCount: subject.studentCount,
              lecturesCount: subject.lectures.length,
              sectionsCount: subject.sections.length,
              quizzesCount: subject.quizzes.length,
              tasksCount: subject.tasks.length,
              progress: subject.progress,
              lastActivityLabel: lastLecture == null
                  ? 'No lecture activity yet'
                  : '${lastLecture.dayLabel} ${lastLecture.timeLabel}',
              statusLabel: subject.progress >= 0.75
                  ? 'Healthy'
                  : subject.progress >= 0.6
                  ? 'Watch'
                  : 'Needs review',
              levelLabel: subject.academicTerm,
              averageScore: result.averageScore,
              pendingGradesCount: result.pendingReviewCount,
              publishedResultsCount: result.publishedResultsCount,
              groupPostsCount: group.postsCount,
              sections: subject.sections
                  .map(
                    (section) => SectionModel(
                      id: _numericId(section.id),
                      name: section.title,
                      code: section.groupLabel,
                      isActive: true,
                      assistantName: section.assistantName,
                    ),
                  )
                  .toList(),
            );
          },
        )
        .toList(growable: false);
  }

  SubjectWorkspaceModel subjectWorkspaceById(int subjectId, SessionUser user) {
    final subject = subjectById(subjectId);
    final summary = subjectModelsFor(user).firstWhere(
      (item) => item.id == subjectId,
      orElse: () => subjectModelsFor(user).first,
    );

    return SubjectWorkspaceModel(
      subject: summary,
      lectures: lecturesFor(user)
          .where((lecture) => lecture.subjectId == subjectId)
          .toList(growable: false),
      sections: sectionContentFor(user)
          .where((section) => section.subjectId == subjectId)
          .toList(growable: false),
      quizzes: quizzesFor(user)
          .where((quiz) => quiz.subjectId == subjectId)
          .toList(growable: false),
      tasks: tasksFor(user)
          .where((task) => task.subjectId == subjectId)
          .toList(growable: false),
      group: subjectGroupById(subjectId, user),
      results: subjectResultsById(subjectId, user),
      students: _students
          .where((student) => student.subjectCode == subject.code)
          .map(
            (student) => SubjectStudentPreviewModel(
              id: _numericId(student.id),
              name: student.name,
              code: student.code,
              sectionLabel: student.sectionLabel,
              statusLabel: student.riskLabel,
              averageScore: student.averageScore,
              attendanceRate: student.attendanceRate,
            ),
          )
          .toList(growable: false),
    );
  }

  List<LectureModel> lecturesFor(SessionUser user) {
    return _subjects
        .expand(
          (subject) => subject.lectures.map(
            (lecture) => LectureModel(
              id: _numericId(lecture.id),
              subjectId: subject.id,
              title: lecture.title,
              weekNumber: _weekNumber(lecture.weekLabel),
              instructorName: _ownerNameForSubject(subject.id),
              subjectName: subject.name,
              description: lecture.description,
              isPublished: lecture.statusLabel.toLowerCase() != 'draft',
              publishedAt: lecture.statusLabel.toLowerCase() == 'draft'
                  ? null
                  : DateTime(2026, 4, 22, 9, 0).toIso8601String(),
              statusLabel: lecture.statusLabel,
              deliveryMode: lecture.deliveryMode ?? 'In person',
              meetingUrl: lecture.meetingUrl,
              startsAt: lecture.startsAtIso,
              endsAt: lecture.endsAtIso,
              locationLabel: lecture.locationLabel ?? lecture.room,
              attachmentLabel: lecture.attachmentLabel,
              publisherName: lecture.publisherName ?? _ownerNameForSubject(subject.id),
            ),
          ),
        )
        .toList(growable: false);
  }

  void saveLecture(Map<String, dynamic> payload, SessionUser user) {
    final existingId = (payload['lecture_id'] as num?)?.toInt();
    final subjectId = (payload['subject_id'] as num?)?.toInt();
    final subject = subjectId == null
        ? _subjectForPayload(payload['subject']?.toString())
        : _subjects.firstWhere(
            (candidate) => candidate.id == subjectId,
            orElse: () => _subjectForPayload(payload['subject']?.toString()),
          );
    final startsAt = _lectureScheduledAtFromPayload(payload);
    final durationMinutes =
        (payload['duration_minutes'] as num?)?.toInt() ?? 120;
    final endsAt = startsAt.add(Duration(minutes: durationMinutes));
    final saveAsDraft = payload['save_as_draft'] == true;
    final publishNow = payload['publish_now'] == true;
    final statusLabel = saveAsDraft
        ? 'Draft'
        : publishNow
        ? (_workspaceNow.isAfter(endsAt) ? 'Delivered' : 'Published')
        : 'Scheduled';
    final lectures = List<TeachingLecture>.from(subject.lectures)
      ..removeWhere((lecture) => _numericId(lecture.id) == existingId);
    lectures.insert(
      0,
      TeachingLecture(
        id: existingId == null ? 'mock-lec-${_nextLectureId++}' : 'mock-lec-$existingId',
        title: payload['title']?.toString() ?? 'Untitled lecture',
        audience: payload['audience']?.toString() ?? payload['scope']?.toString() ?? 'All groups',
        dayLabel: _weekdayName(startsAt.weekday),
        timeLabel: _timeRangeLabel(
          startsAt,
          durationMinutes,
          fallback: payload['publish_time']?.toString() ?? '09:00 - 11:00',
        ),
        room:
            payload['location_label']?.toString() ??
            _roomFromNotes(payload['notes']?.toString()),
        statusLabel: statusLabel,
        weekLabel: 'Week ${payload['week_number'] ?? subject.lectures.length + 8}',
        description: payload['description']?.toString(),
        startsAtIso: startsAt.toIso8601String(),
        endsAtIso: endsAt.toIso8601String(),
        deliveryMode: payload['delivery_mode']?.toString() ?? 'In person',
        meetingUrl: payload['meeting_url']?.toString(),
        locationLabel: payload['location_label']?.toString(),
        attachmentLabel:
            payload['attachment_label']?.toString() ??
            payload['attachment_name']?.toString(),
        publisherName: user.fullName,
      ),
    );
    _replaceSubject(subject, _cloneSubject(subject, lectures: lectures));
  }

  void publishLecture(int lectureId) {
    for (var index = 0; index < _subjects.length; index++) {
      final subject = _subjects[index];
      final lectures = subject.lectures
          .map(
            (lecture) => _numericId(lecture.id) == lectureId
                ? _copyLecture(lecture, statusLabel: 'Published')
                : lecture,
          )
          .toList(growable: false);
      if (lectures.any((lecture) => _numericId(lecture.id) == lectureId)) {
        _subjects[index] = _cloneSubject(subject, lectures: lectures);
        return;
      }
    }
  }

  void deleteLecture(int lectureId) {
    for (var index = 0; index < _subjects.length; index++) {
      final subject = _subjects[index];
      final filtered = subject.lectures
          .where((lecture) => _numericId(lecture.id) != lectureId)
          .toList(growable: false);
      if (filtered.length != subject.lectures.length) {
        _subjects[index] = _cloneSubject(subject, lectures: filtered);
        break;
      }
    }
  }

  List<SectionContentModel> sectionContentFor(SessionUser user) {
    return _subjects
        .expand(
          (subject) => subject.sections.map(
            (section) => SectionContentModel(
              id: _numericId(section.id),
              subjectId: subject.id,
              title: section.title,
              weekNumber: _weekNumber(section.groupLabel),
              assistantName: section.assistantName,
              isPublished: section.statusLabel.toLowerCase() != 'draft',
              publishedAt: section.statusLabel.toLowerCase() == 'draft'
                  ? null
                  : DateTime(2026, 4, 22, 8, 0).toIso8601String(),
            ),
          ),
        )
        .toList(growable: false);
  }

  void saveSectionContent(Map<String, dynamic> payload, SessionUser user) {
    final existingId = (payload['existing_id'] as num?)?.toInt();
    final subjectId = (payload['subject_id'] as num?)?.toInt();
    final subject = subjectId == null
        ? _subjectForPayload(payload['subject']?.toString())
        : _subjects.firstWhere(
            (candidate) => candidate.id == subjectId,
            orElse: () => _subjectForPayload(payload['subject']?.toString()),
          );
    final existingSection = existingId == null ? null : sectionById(existingId);
    final existingSubject = existingId == null
        ? null
        : subjectBySectionId(existingId);
    final scheduledAt = _sectionScheduledAtFromPayload(payload);
    final statusLabel = _sectionStatusLabel(
      scheduledAt: scheduledAt,
      publishImmediately: payload['publish_immediately'] == true,
      saveAsDraft: payload['save_as_draft'] == true,
    );
    final deliveryMode = payload['section_type']?.toString() ?? 'In person';
    final locationLabel =
        payload['location_label']?.toString() ??
        payload['location_or_link']?.toString() ??
        payload['meeting_link']?.toString() ??
        _roomFromNotes(payload['notes']?.toString());
    final durationMinutes =
        (payload['duration_minutes'] as num?)?.toInt() ?? 90;
    final expectedStudents =
        (payload['expected_students'] as num?)?.toInt() ??
        _expectedStudentsForSectionSubject(subject);
    final nextSection = TeachingSection(
      id: existingSection?.id ?? 'mock-sec-${_nextSectionId++}',
      title: payload['title']?.toString() ?? 'Untitled section',
      assistantName: user.fullName,
      dayLabel: _weekdayName(scheduledAt.weekday),
      timeLabel: _timeRangeLabel(
        scheduledAt,
        durationMinutes,
        fallback: payload['schedule']?.toString() ?? '12:00 - 13:30',
      ),
      room: locationLabel,
      statusLabel: statusLabel,
      groupLabel:
          payload['audience']?.toString() ??
          payload['scope']?.toString() ??
          existingSection?.groupLabel ??
          'Section group',
      description: payload['description']?.toString(),
      scheduledAtIso: scheduledAt.toIso8601String(),
      durationMinutes: durationMinutes,
      deliveryMode: deliveryMode,
      locationLabel: locationLabel,
      meetingLink: payload['meeting_link']?.toString(),
      notes: payload['notes']?.toString(),
      expectedStudents: expectedStudents,
      addedToSchedule: payload['add_to_schedule'] == true,
      sendNotification: payload['send_notification'] == true,
      attachmentName: payload['attachment_name']?.toString(),
    );

    if (existingId != null &&
        existingSubject != null &&
        existingSubject.id != subject.id) {
      final filteredSections = existingSubject.sections
          .where((section) => _numericId(section.id) != existingId)
          .toList(growable: false);
      _replaceSubject(
        existingSubject,
        _cloneSubject(existingSubject, sections: filteredSections),
      );
    }

    final sections = List<TeachingSection>.from(subject.sections);
    final existingIndex = sections.indexWhere(
      (section) => _numericId(section.id) == existingId,
    );
    if (existingIndex != -1) {
      sections[existingIndex] = nextSection;
    } else {
      sections.insert(0, nextSection);
    }
    _replaceSubject(subject, _cloneSubject(subject, sections: sections));
  }

  void publishSection(int sectionId) {
    final subject = subjectBySectionId(sectionId);
    final section = sectionById(sectionId);
    if (subject == null || section == null) {
      return;
    }

    final scheduledAt =
        DateTime.tryParse(section.scheduledAtIso ?? '') ??
        _workspaceNow.add(const Duration(hours: 1));
    final durationMinutes = section.durationMinutes ?? 90;
    final endAt = scheduledAt.add(Duration(minutes: durationMinutes));
    final nextStatus = _workspaceNow.isAfter(endAt)
        ? 'Finished'
        : _workspaceNow.isAfter(scheduledAt)
        ? 'Live'
        : 'Published';

    final sections = subject.sections
        .map(
          (item) => _numericId(item.id) == sectionId
              ? _copySection(item, statusLabel: nextStatus)
              : item,
        )
        .toList(growable: false);
    _replaceSubject(subject, _cloneSubject(subject, sections: sections));
  }

  List<QuizModel> quizzesFor(SessionUser user) {
    return _subjects
        .expand(
          (subject) => subject.quizzes.map(
            (quiz) => QuizModel(
              id: _numericId(quiz.id),
              subjectId: subject.id,
              title: quiz.title,
              ownerName: _ownerNameForSubject(subject.id),
              quizType: quiz.statusLabel.toLowerCase() == 'draft'
                  ? 'draft'
                  : 'graded',
              quizDate: quiz.windowLabel,
              isPublished: quiz.statusLabel.toLowerCase() != 'draft',
              quizLink: 'mock://quizzes/${quiz.id}',
            ),
          ),
        )
        .toList(growable: false);
  }

  void saveQuiz(Map<String, dynamic> payload, SessionUser user) {
    final existingId = (payload['existing_id'] as num?)?.toInt();
    final subjectId = (payload['subject_id'] as num?)?.toInt();
    final subject = subjectId == null
        ? _subjectForPayload(payload['subject']?.toString())
        : _subjects.firstWhere(
            (candidate) => candidate.id == subjectId,
            orElse: () => _subjectForPayload(payload['subject']?.toString()),
          );
    final existingQuiz = existingId == null ? null : quizById(existingId);
    final existingSubject = existingId == null
        ? null
        : subjectByQuizId(existingId);
    final startAt = _quizStartAtFromPayload(payload);
    final durationMinutes =
        (payload['duration_minutes'] as num?)?.toInt() ?? 30;
    final endAt = _quizEndAtFromPayload(payload, startAt, durationMinutes);
    final statusLabel = _quizStatusLabel(
      startAt: startAt,
      endAt: endAt,
      publishImmediately: payload['publish_immediately'] == true,
      saveAsDraft: payload['save_as_draft'] == true,
    );
    final questions = _quizQuestionsFromPayload(payload);
    final rawId = 'mock-quiz-${_nextQuizId++}';
    final totalStudents =
        (payload['total_students'] as num?)?.toInt() ?? subject.studentCount;
    final enteredStudents = statusLabel == 'Draft'
        ? 0
        : ((totalStudents * 0.62).round()).clamp(0, totalStudents);
    final completedStudents = statusLabel == 'Draft'
        ? 0
        : ((enteredStudents * 0.81).round()).clamp(0, enteredStudents);
    final nextQuiz = TeachingQuiz(
      id: existingQuiz?.id ?? rawId,
      title: payload['title']?.toString() ?? 'Untitled quiz',
      windowLabel: _quizWindowLabel(
        startAt: startAt,
        endAt: endAt,
        durationMinutes: durationMinutes,
      ),
      statusLabel: statusLabel,
      attemptsLabel: statusLabel == 'Draft'
          ? 'Awaiting publish'
          : '$enteredStudents/$totalStudents attempts',
      scopeLabel:
          payload['audience']?.toString() ??
          payload['scope']?.toString() ??
          existingQuiz?.scopeLabel ??
          'Target cohort',
      description: payload['description']?.toString(),
      startAtIso: startAt.toIso8601String(),
      endAtIso: endAt.toIso8601String(),
      durationMinutes: durationMinutes,
      attemptsAllowed: (payload['attempts_allowed'] as num?)?.toInt() ?? 1,
      totalMarks: _totalMarksFromPayload(payload, questions),
      questionCount: questions.length,
      audienceLabel:
          payload['audience']?.toString() ??
          payload['scope']?.toString() ??
          existingQuiz?.audienceLabel ??
          'Target cohort',
      totalStudents: totalStudents,
      enteredStudents: enteredStudents,
      completedStudents: completedStudents,
      passRate: statusLabel == 'Draft' ? 0 : 73,
      averageScore: statusLabel == 'Draft' ? 0 : 76,
      liveParticipants: statusLabel == 'Open'
          ? (enteredStudents - completedStudents).clamp(0, enteredStudents)
          : 0,
      attachmentName: payload['attachment_name']?.toString(),
      questions: questions,
      submissions: _quizSubmissionsFromPayload(
        payload: payload,
        totalStudents: totalStudents,
        enteredStudents: enteredStudents,
        completedStudents: completedStudents,
      ),
    );

    if (existingId != null &&
        existingSubject != null &&
        existingSubject.id != subject.id) {
      final filteredQuizzes = existingSubject.quizzes
          .where((quiz) => _numericId(quiz.id) != existingId)
          .toList(growable: false);
      _replaceSubject(
        existingSubject,
        _cloneSubject(existingSubject, quizzes: filteredQuizzes),
      );
    }

    final quizzes = List<TeachingQuiz>.from(subject.quizzes);
    final existingIndex = quizzes.indexWhere(
      (quiz) => _numericId(quiz.id) == existingId,
    );
    if (existingIndex != -1) {
      quizzes[existingIndex] = nextQuiz;
    } else {
      quizzes.insert(0, nextQuiz);
    }
    _replaceSubject(subject, _cloneSubject(subject, quizzes: quizzes));
  }

  void publishQuiz(int quizId) {
    final subject = subjectByQuizId(quizId);
    final quiz = quizById(quizId);
    if (subject == null || quiz == null) {
      return;
    }

    final startAt =
        DateTime.tryParse(quiz.startAtIso ?? '') ??
        _workspaceNow.add(const Duration(hours: 2));
    final endAt =
        DateTime.tryParse(quiz.endAtIso ?? '') ??
        startAt.add(Duration(minutes: quiz.durationMinutes ?? 30));
    final nextStatus = _workspaceNow.isBefore(startAt)
        ? 'Scheduled'
        : _workspaceNow.isAfter(endAt)
        ? 'Closed'
        : 'Open';
    final totalStudents = quiz.totalStudents ?? subject.studentCount;
    final enteredStudents =
        quiz.enteredStudents == null || quiz.enteredStudents == 0
        ? ((totalStudents * 0.62).round()).clamp(0, totalStudents)
        : quiz.enteredStudents!;
    final completedStudents =
        (quiz.completedStudents ?? ((enteredStudents * 0.81).round())).clamp(
          0,
          enteredStudents,
        );

    final quizzes = subject.quizzes
        .map(
          (item) => _numericId(item.id) == quizId
              ? _copyQuiz(
                  item,
                  statusLabel: nextStatus,
                  attemptsLabel: _quizAttemptsLabel(
                    statusLabel: nextStatus,
                    enteredStudents: enteredStudents,
                    totalStudents: totalStudents,
                  ),
                  enteredStudents: enteredStudents,
                  completedStudents: completedStudents,
                  passRate: nextStatus == 'Draft' ? 0 : (item.passRate ?? 73),
                  averageScore: nextStatus == 'Draft'
                      ? 0
                      : (item.averageScore ?? 76),
                  liveParticipants: nextStatus == 'Open'
                      ? (enteredStudents - completedStudents).clamp(
                          0,
                          enteredStudents,
                        )
                      : 0,
                )
              : item,
        )
        .toList(growable: false);
    _replaceSubject(subject, _cloneSubject(subject, quizzes: quizzes));
  }

  void closeQuiz(int quizId) {
    final subject = subjectByQuizId(quizId);
    final quiz = quizById(quizId);
    if (subject == null || quiz == null) {
      return;
    }

    final totalStudents = quiz.totalStudents ?? subject.studentCount;
    final enteredStudents = quiz.enteredStudents ?? totalStudents;
    final completedStudents =
        quiz.completedStudents ?? enteredStudents.clamp(0, totalStudents);
    final quizzes = subject.quizzes
        .map(
          (item) => _numericId(item.id) == quizId
              ? _copyQuiz(
                  item,
                  statusLabel: 'Closed',
                  endAtIso: _workspaceNow.toIso8601String(),
                  attemptsLabel: _quizAttemptsLabel(
                    statusLabel: 'Closed',
                    enteredStudents: enteredStudents,
                    totalStudents: totalStudents,
                  ),
                  liveParticipants: 0,
                  completedStudents: completedStudents,
                )
              : item,
        )
        .toList(growable: false);
    _replaceSubject(subject, _cloneSubject(subject, quizzes: quizzes));
  }

  void duplicateQuiz(int quizId) {
    final subject = subjectByQuizId(quizId);
    final quiz = quizById(quizId);
    if (subject == null || quiz == null) {
      return;
    }

    final duplicated = _copyQuiz(
      quiz,
      id: 'mock-quiz-${_nextQuizId++}',
      title: '${quiz.title} Copy',
      statusLabel: 'Draft',
      attemptsLabel: 'Awaiting publish',
      enteredStudents: 0,
      completedStudents: 0,
      passRate: 0,
      averageScore: 0,
      liveParticipants: 0,
      submissions: const <TeachingQuizSubmission>[],
    );
    final quizzes = List<TeachingQuiz>.from(subject.quizzes)
      ..insert(0, duplicated);
    _replaceSubject(subject, _cloneSubject(subject, quizzes: quizzes));
  }

  List<TaskModel> tasksFor(SessionUser user) {
    return _subjects
        .expand(
          (subject) => subject.tasks.map(
            (task) => TaskModel(
              id: _numericId(task.id),
              subjectId: subject.id,
              title: task.title,
              ownerName: _ownerNameForSubject(subject.id),
              referenceName: task.scopeLabel,
              dueDate: task.deadlineLabel,
              isPublished: task.statusLabel.toLowerCase() == 'published',
              fileUrl: 'mock://tasks/${task.id}',
            ),
          ),
        )
        .toList(growable: false);
  }

  void saveTask(Map<String, dynamic> payload, SessionUser user) {
    final subjectId = (payload['subject_id'] as num?)?.toInt();
    final subject = subjectId == null
        ? _subjectForPayload(payload['subject']?.toString())
        : _subjects.firstWhere(
            (candidate) => candidate.id == subjectId,
            orElse: () => _subjectForPayload(payload['subject']?.toString()),
          );
    final publishImmediately = payload['publish_immediately'] == true;
    final addToSchedule = payload['add_to_schedule'] == true;
    final statusLabel = publishImmediately
        ? 'Published'
        : addToSchedule
        ? 'Scheduled'
        : 'Draft';
    final progressLabel = publishImmediately
        ? '0% submitted'
        : addToSchedule
        ? 'Scheduled for release'
        : 'Awaiting publish';
    final tasks = List<TeachingTask>.from(subject.tasks)
      ..insert(
        0,
        TeachingTask(
          id: 'mock-task-${_nextTaskId++}',
          title: payload['title']?.toString() ?? 'Untitled task',
          deadlineLabel:
              payload['deadline_label']?.toString() ??
              payload['schedule']?.toString() ??
              'Due Thu 17 Apr',
          statusLabel: statusLabel,
          progressLabel: progressLabel,
          scopeLabel:
              payload['audience']?.toString() ??
              payload['scope']?.toString() ??
              'Assigned cohort',
        ),
      );
    _replaceSubject(subject, _cloneSubject(subject, tasks: tasks));
  }

  List<NotificationModel> notificationModelsFor(SessionUser user) {
    return _notifications
        .map(
          (item) => NotificationModel(
            id: int.tryParse(item.id) ?? _numericId(item.id),
            title: item.title,
            body: item.body,
            category: item.courseLabel,
            isRead: item.isRead,
            createdAt: DateTime(2026, 4, 22, 10, 0).toIso8601String(),
          ),
        )
        .toList(growable: false);
  }

  List<WorkspaceNotificationItem> notificationsFor(SessionUser user) =>
      List<WorkspaceNotificationItem>.unmodifiable(_notifications);

  void markNotificationRead(int notificationId) {
    final index = _notifications.indexWhere(
      (item) =>
          (int.tryParse(item.id) ?? _numericId(item.id)) == notificationId,
    );
    if (index == -1) {
      return;
    }
    final current = _notifications[index];
    _notifications[index] = WorkspaceNotificationItem(
      id: current.id,
      title: current.title,
      body: current.body,
      timeLabel: current.timeLabel,
      statusLabel: current.statusLabel,
      courseLabel: current.courseLabel,
      isRead: true,
      icon: current.icon,
    );
  }

  int unreadNotificationsFor(SessionUser user) =>
      _notifications.where((notification) => !notification.isRead).length;

  List<UploadModel> uploadsFor(SessionUser user) =>
      List<UploadModel>.unmodifiable(_uploads);

  void addUpload({
    required String name,
    required String mimeType,
    required int sizeBytes,
  }) {
    final sizeInMb = sizeBytes / (1024 * 1024);
    _uploads.insert(
      0,
      UploadModel(
        id: _nextUploadId++,
        name: name,
        mimeType: mimeType.toUpperCase(),
        sizeLabel: sizeInMb >= 1
            ? '${sizeInMb.toStringAsFixed(1)} MB'
            : '${max(1, (sizeBytes / 1024).round())} KB',
        url: 'mock://uploads/${name.toLowerCase().replaceAll(' ', '-')}',
      ),
    );
  }

  List<ScheduleEventItem> scheduleFor(SessionUser user) =>
      List<ScheduleEventItem>.unmodifiable(_schedule);

  List<ScheduleEventModel> scheduleModelsFor(SessionUser user) {
    return _schedule
        .map(
          (event) => ScheduleEventModel(
            id: _numericId(event.id),
            title: event.title,
            eventType: event.type.label,
            eventDate:
                '${event.startAt.year}-${event.startAt.month.toString().padLeft(2, '0')}-${event.startAt.day.toString().padLeft(2, '0')}',
            colorKey: event.type.name,
            startTime:
                '${event.startAt.hour.toString().padLeft(2, '0')}:${event.startAt.minute.toString().padLeft(2, '0')}',
            endTime:
                '${event.endAt.hour.toString().padLeft(2, '0')}:${event.endAt.minute.toString().padLeft(2, '0')}',
            location: event.location,
          ),
        )
        .toList(growable: false);
  }

  Map<String, List<String>> scheduleConflictsFor(SessionUser user) => const {
    'evt-quiz-se': ['Assessment overlaps with section A2 support coverage.'],
  };

  WorkspaceProfileSnapshot profileFor(SessionUser user) {
    final account = _accountForUser(user);
    final primaryStats = user.isDoctor
        ? <WorkspaceOverviewMetric>[
            WorkspaceOverviewMetric(
              label: 'Active Subjects',
              value: '${subjectsFor(user).length}',
              caption: 'Courses currently under direct supervision',
              icon: Icons.menu_book_rounded,
              color: AppColors.primary,
            ),
            WorkspaceOverviewMetric(
              label: 'Weekly Hours',
              value: '18',
              caption: 'Lectures, office hours, and review time',
              icon: Icons.schedule_rounded,
              color: AppColors.info,
            ),
            WorkspaceOverviewMetric(
              label: 'Students Tracked',
              value: '${studentsFor(user).length * 31}',
              caption: 'Students monitored through mock analytics',
              icon: Icons.groups_rounded,
              color: AppColors.secondary,
            ),
          ]
        : <WorkspaceOverviewMetric>[
            WorkspaceOverviewMetric(
              label: 'Supported Sections',
              value:
                  '${subjectsFor(user).fold<int>(0, (sum, subject) => sum + subject.sections.length)}',
              caption: 'Labs and tutorials currently coordinated',
              icon: Icons.widgets_rounded,
              color: AppColors.primary,
            ),
            WorkspaceOverviewMetric(
              label: 'Weekly Hours',
              value: '16',
              caption: 'Delivery support and student follow-up',
              icon: Icons.schedule_rounded,
              color: AppColors.info,
            ),
            WorkspaceOverviewMetric(
              label: 'Open Tasks',
              value:
                  '${tasksFor(user).where((task) => !task.isPublished).length + 7}',
              caption: 'Drafts and support actions in flight',
              icon: Icons.pending_actions_rounded,
              color: AppColors.warning,
            ),
          ];

    return WorkspaceProfileSnapshot(
      roleHeadline: user.isDoctor
          ? 'Lead academic delivery across core subjects.'
          : user.isAdmin
          ? 'Coordinate staff operations, visibility, and academic execution.'
          : 'Coordinate sections, support delivery, and keep weekly execution tight.',
      roleSummary: user.isDoctor
          ? 'This profile is tuned for lecture publishing, assessment cadence, and course-level visibility.'
          : user.isAdmin
          ? 'This profile highlights governance, staffing, and operational readiness using the same frontend mock data layer.'
          : 'This profile highlights section readiness, grading support, and student follow-up with local sample data.',
      focusAreas: List<String>.from(
        account?.focusAreas ?? const ['Academic Delivery'],
      ),
      officeHours: account?.officeHours ?? 'Sun - Thu, 09:00 - 15:00',
      locationLabel: account?.locationLabel ?? 'Campus Office',
      phoneLabel: account?.user.phone ?? '+20 100 555 0101',
      primaryStats: primaryStats,
    );
  }

  List<StaffMemberModel> staffMembers() {
    return _accountsByEmail.values
        .map(
          (account) => StaffMemberModel(
            user: account.user,
            departmentName: account.department,
            assignmentSummary: account.user.isAdmin
                ? 'Approvals, staffing, and operational reviews'
                : account.user.isDoctor
                ? 'Lectures, assessments, and subject ownership'
                : 'Sections, grading support, and student follow-up',
          ),
        )
        .toList(growable: false);
  }

  Map<String, dynamic> adminOverview() =>
      Map<String, dynamic>.from(MockSamplePayloads.adminOverview);

  List<String> adminPermissions() =>
      List<String>.from(MockSamplePayloads.adminPermissions);

  List<DepartmentModel> departments() =>
      List<DepartmentModel>.unmodifiable(_departments);

  void toggleStaffActivation(int userId, bool isActive) {
    final account = _accountsByEmail.values.firstWhere(
      (candidate) => candidate.user.id == userId,
      orElse: () => _accountsByEmail.values.first,
    );
    final nextUser = SessionUser(
      id: account.user.id,
      fullName: account.user.fullName,
      universityEmail: account.user.universityEmail,
      roleType: account.user.roleType,
      isActive: isActive,
      avatar: account.user.avatar,
      phone: account.user.phone,
      notificationEnabled: account.user.notificationEnabled,
      language: account.user.language,
      permissions: List<String>.from(account.user.permissions),
    );
    _accountsByEmail[nextUser.universityEmail.toLowerCase()] = account.copyWith(
      user: nextUser,
    );
  }

  List<MockStudentResult> resultsFor(SessionUser user) =>
      List<MockStudentResult>.unmodifiable(_results);

  ResultsOverviewModel resultsOverviewFor(SessionUser user) {
    final subjects = subjectModelsFor(user);
    final summaries = subjects
        .map((subject) => subjectResultsById(subject.id, user))
        .map(
          (result) => SubjectResultsSummaryModel(
            subjectId: result.subjectId,
            subjectName: result.subjectName,
            subjectCode: result.subjectCode,
            statusLabel: result.statusLabel,
            latestActivityLabel: result.recentActivity.isEmpty
                ? 'No grading activity yet'
                : result.recentActivity.first.title,
            averageScore: result.averageScore,
            pendingReviewCount: result.pendingReviewCount,
            publishedResultsCount: result.publishedResultsCount,
            studentsCount: result.students.length,
          ),
        )
        .toList(growable: false);

    final pending = <GradingActivityItem>[];
    final published = <GradingActivityItem>[];
    final review = <GradingActivityItem>[];
    for (final result in summaries) {
      pending.add(
        GradingActivityItem(
          id: result.subjectId,
          title: '${result.subjectCode} draft queue',
          subtitle: '${result.pendingReviewCount} students still need grades review',
          statusLabel: 'Draft',
          createdAt: _workspaceNow.subtract(Duration(hours: result.subjectId % 6 + 1)),
        ),
      );
      published.add(
        GradingActivityItem(
          id: result.subjectId + 1000,
          title: '${result.subjectCode} published batches',
          subtitle: '${result.publishedResultsCount} grade sets are visible to students',
          statusLabel: 'Published',
          createdAt: _workspaceNow.subtract(Duration(days: result.subjectId % 3)),
        ),
      );
      review.add(
        GradingActivityItem(
          id: result.subjectId + 2000,
          title: '${result.subjectCode} moderation',
          subtitle: result.pendingReviewCount == 0
              ? 'No pending review blocks'
              : '${result.pendingReviewCount} rows should be checked before release',
          statusLabel: result.pendingReviewCount == 0 ? 'Published' : 'Needs review',
          createdAt: _workspaceNow.subtract(Duration(hours: result.subjectId % 4 + 2)),
        ),
      );
    }

    return ResultsOverviewModel(
      subjects: summaries,
      pendingGrades: pending,
      recentlyPublished: published,
      needsReview: review,
      analytics: GradeAnalyticsModel(
        averageScore: summaries.isEmpty
            ? 0
            : summaries.fold<double>(0, (sum, item) => sum + item.averageScore) /
                summaries.length,
        missingGrades: summaries.fold<int>(
          0,
          (sum, item) => sum + item.pendingReviewCount,
        ),
        attendanceCompletion: 88,
        gradedQuizzes: 17,
        pendingQuizzes: 5,
        topPerformerLabel: _students.isEmpty ? '' : _students.first.name,
        lowPerformerLabel: _students.isEmpty ? '' : _students.last.name,
      ),
    );
  }

  SubjectResultsModel subjectResultsById(int subjectId, SessionUser user) {
    _ensureGradebookSeeded();
    final subject = subjectById(subjectId);
    final students = _students
        .where((student) => student.subjectCode == subject.code)
        .toList(growable: false);
    final blueprints = _categoryBlueprintsFor(user);
    final categoryStore = _gradesBySubject[subjectId] ?? const {};
    final categories = blueprints
        .map((blueprint) {
          final entries = categoryStore[blueprint.key]?.values.toList() ?? const [];
          final gradedCount = entries.where((entry) => entry.score != null).length;
          final missingCount = students.length - gradedCount;
          final averageScore = entries.isEmpty
              ? 0.0
              : entries
                      .where((entry) => entry.score != null)
                      .fold<double>(0, (sum, entry) => sum + (entry.score ?? 0)) /
                  max(1, gradedCount);
          final statusLabel = entries.any((entry) => entry.statusLabel == 'Needs review')
              ? 'Needs review'
              : entries.any((entry) => entry.statusLabel == 'Draft')
              ? 'Draft'
              : 'Published';
          return GradeCategoryModel(
            key: blueprint.key,
            label: blueprint.label,
            maxScore: blueprint.maxScore,
            statusLabel: statusLabel,
            averageScore: averageScore,
            gradedCount: gradedCount,
            missingCount: missingCount,
            isEditable: _allowedCategoryKeys(user).contains(blueprint.key),
          );
        })
        .toList(growable: false);

    final rows = students.map((student) {
      final entries = <String, GradeEntryValueModel>{};
      for (final blueprint in blueprints) {
        final stored = categoryStore[blueprint.key]?[student.code];
        entries[blueprint.key] = GradeEntryValueModel(
          score: stored?.score,
          maxScore: stored?.maxScore ?? blueprint.maxScore,
          statusLabel: stored?.statusLabel ?? 'Draft',
          note: stored?.note,
        );
      }

      final statusLabel = entries.values.any((entry) => entry.statusLabel == 'Needs review')
          ? 'Needs review'
          : entries.values.any((entry) => entry.statusLabel == 'Draft')
          ? 'Draft'
          : 'Published';

      return GradeStudentRowModel(
        studentId: _numericId(student.id),
        studentName: student.name,
        studentCode: student.code,
        statusLabel: statusLabel,
        notes: student.riskLabel,
        entries: entries,
      );
    }).toList(growable: false);

    final recentActivity = blueprints
        .take(4)
        .map(
          (blueprint) => GradingActivityItem(
            id: subjectId + blueprint.key.hashCode.abs(),
            title: '${blueprint.label} updated',
            subtitle: '${subject.code} · ${_allowedCategoryKeys(user).contains(blueprint.key) ? 'Editable' : 'View only'}',
            statusLabel: categories
                .firstWhere((category) => category.key == blueprint.key)
                .statusLabel,
            createdAt: _workspaceNow.subtract(Duration(hours: blueprint.key.length + 1)),
          ),
        )
        .toList(growable: false);

    final averageScore = rows.isEmpty
        ? 0.0
        : rows
                .map(
                  (row) => row.entries.values.fold<double>(
                    0,
                    (sum, entry) => sum + (entry.score ?? 0),
                  ),
                )
                .fold<double>(0, (sum, value) => sum + value) /
            rows.length;
    final pendingReviewCount = rows
        .where((row) => row.statusLabel != 'Published')
        .length;
    final publishedResultsCount = categories
        .where((category) => category.statusLabel == 'Published')
        .length;

    return SubjectResultsModel(
      subjectId: subjectId,
      subjectName: subject.name,
      subjectCode: subject.code,
      statusLabel: pendingReviewCount == 0 ? 'Published' : 'Needs review',
      categories: categories,
      students: rows,
      recentActivity: recentActivity,
      analytics: GradeAnalyticsModel(
        averageScore: averageScore,
        missingGrades: categories.fold<int>(
          0,
          (sum, category) => sum + category.missingCount,
        ),
        attendanceCompletion: 91,
        gradedQuizzes: categories
            .where((category) => category.key == 'quiz' && category.gradedCount > 0)
            .length,
        pendingQuizzes: categories
            .where((category) => category.key == 'quiz' && category.missingCount > 0)
            .length,
        topPerformerLabel: rows.isEmpty ? '' : rows.first.studentName,
        lowPerformerLabel: rows.isEmpty ? '' : rows.last.studentName,
      ),
      allowedCategoryKeys: _allowedCategoryKeys(user),
      averageScore: averageScore,
      pendingReviewCount: pendingReviewCount,
      publishedResultsCount: publishedResultsCount,
    );
  }

  void saveGrades(
    int subjectId,
    Map<String, dynamic> payload,
    SessionUser user, {
    required bool publish,
  }) {
    _ensureGradebookSeeded();
    final categoryKey = payload['category_key']?.toString() ?? '';
    if (!_allowedCategoryKeys(user).contains(categoryKey)) {
      throw Exception('You do not have permission to update $categoryKey grades.');
    }

    final maxScore = (payload['max_score'] as num?)?.toDouble() ??
        _categoryBlueprintsFor(user)
            .firstWhere((item) => item.key == categoryKey)
            .maxScore;
    final subjectGrades = _gradesBySubject.putIfAbsent(subjectId, () => {});
    final categoryGrades = subjectGrades.putIfAbsent(categoryKey, () => {});
    for (final rawEntry in (payload['entries'] as List? ?? const [])) {
      if (rawEntry is! Map) {
        continue;
      }
      final studentCode = rawEntry['student_code']?.toString() ?? '';
      if (studentCode.isEmpty) {
        continue;
      }
      categoryGrades[studentCode] = _StoredGrade(
        score: (rawEntry['score'] as num?)?.toDouble(),
        maxScore: maxScore,
        note: rawEntry['note']?.toString(),
        statusLabel: publish ? 'Published' : 'Draft',
      );
    }
  }

  List<MockAnnouncementItem> announcementsFor(SessionUser user) =>
      List<MockAnnouncementItem>.unmodifiable(_announcements);

  List<MockStudentDirectoryEntry> studentsFor(SessionUser user) =>
      List<MockStudentDirectoryEntry>.unmodifiable(_students);

  List<MockGroupPost> groupPostsFor(SessionUser user) =>
      List<MockGroupPost>.unmodifiable(_groupPosts);

  SubjectGroupModel subjectGroupById(int subjectId, SessionUser user) {
    _ensureSubjectGroupsSeeded();
    final subject = subjectById(subjectId);
    final posts = List<GroupPostModel>.from(_subjectPosts[subjectId] ?? const []);
    final latestComments = posts
        .expand((post) => post.comments)
        .toList()
      ..sort((left, right) => right.createdAt.compareTo(left.createdAt));
    final activity = <GroupActivityItem>[
      for (final post in posts.take(5))
        GroupActivityItem(
          id: post.id,
          title: post.title,
          subtitle: '${post.authorName} · ${post.commentsCount} comments',
          type: post.type,
          createdAt: post.createdAt,
        ),
      for (final comment in latestComments.take(3))
        GroupActivityItem(
          id: comment.id,
          title: 'New comment from ${comment.authorName}',
          subtitle: comment.message,
          type: 'comment',
          createdAt: comment.createdAt,
        ),
    ]..sort((left, right) => right.createdAt.compareTo(left.createdAt));

    return SubjectGroupModel(
      subjectId: subjectId,
      subjectName: subject.name,
      subjectCode: subject.code,
      groupName: '${subject.code} Course Group',
      summary:
          'Announcements, course posts, and comment threads stay aligned to the teaching team for ${subject.name}.',
      posts: posts,
      latestComments: latestComments.take(6).toList(growable: false),
      activity: activity.take(8).toList(growable: false),
      postsCount: posts.length,
      commentsCount: latestComments.length,
      engagementCount: posts.fold<int>(
        0,
        (sum, post) => sum + post.commentsCount + post.reactionsCount,
      ),
    );
  }

  void saveGroupPost(int subjectId, Map<String, dynamic> payload, SessionUser user) {
    _ensureSubjectGroupsSeeded();
    final posts = _subjectPosts.putIfAbsent(subjectId, () => <GroupPostModel>[]);
    final postId = (payload['post_id'] as num?)?.toInt();
    final existingIndex = posts.indexWhere((post) => post.id == postId);
    final now = _workspaceNow.subtract(Duration(minutes: posts.length + 1));
    final current = existingIndex == -1 ? null : posts[existingIndex];
    final nextPost = GroupPostModel(
      id: postId ?? _nextPostId++,
      subjectId: subjectId,
      title: payload['title']?.toString() ?? 'Untitled post',
      content: payload['content']?.toString() ?? '',
      authorName: user.fullName,
      authorRole: user.isDoctor ? 'Doctor' : 'Assistant',
      createdAt: current?.createdAt ?? now,
      updatedAt: now,
      type: payload['post_type']?.toString() ?? 'post',
      priority: payload['priority']?.toString() ?? 'normal',
      isPinned: payload['is_pinned'] == true || current?.isPinned == true,
      attachmentLabel: payload['attachment_label']?.toString(),
      attachmentUrl: payload['attachment_url']?.toString(),
      commentsCount: current?.commentsCount ?? 0,
      reactionsCount: current?.reactionsCount ?? 0,
      comments: current?.comments ?? const <GroupCommentModel>[],
    );
    if (existingIndex == -1) {
      posts.insert(0, nextPost);
    } else {
      posts[existingIndex] = nextPost;
    }
  }

  void deleteGroupPost(int postId) {
    for (final subjectId in _subjectPosts.keys) {
      _subjectPosts[subjectId] = (_subjectPosts[subjectId] ?? const [])
          .where((post) => post.id != postId)
          .toList(growable: false);
    }
  }

  void togglePinnedPost(int postId) {
    for (final entry in _subjectPosts.entries) {
      final posts = entry.value;
      final hasPost = posts.any((post) => post.id == postId);
      if (!hasPost) {
        continue;
      }
      final nextPosts = posts
          .map(
            (post) => GroupPostModel(
              id: post.id,
              subjectId: post.subjectId,
              title: post.title,
              content: post.content,
              authorName: post.authorName,
              authorRole: post.authorRole,
              createdAt: post.createdAt,
              updatedAt: post.updatedAt,
              type: post.type,
              priority: post.priority,
              isPinned: post.id == postId ? !post.isPinned : false,
              comments: post.comments,
              commentsCount: post.commentsCount,
              reactionsCount: post.reactionsCount,
              attachmentLabel: post.attachmentLabel,
              attachmentUrl: post.attachmentUrl,
            ),
          )
          .toList(growable: false)
        ..sort((left, right) {
          if (left.isPinned == right.isPinned) {
            return right.createdAt.compareTo(left.createdAt);
          }
          return left.isPinned ? -1 : 1;
        });
      _subjectPosts[entry.key] = nextPosts;
      return;
    }
  }

  List<MockMessageThread> messageThreadsFor(SessionUser user) =>
      List<MockMessageThread>.unmodifiable(_messageThreads);

  MockAnalyticsSnapshot analyticsFor(SessionUser user) {
    final averageScore =
        _results.fold<double>(0, (sum, item) => sum + item.percentage) /
        max(1, _results.length);

    return MockAnalyticsSnapshot(
      summary:
          'Mock analytics combine student engagement, grade momentum, and subject health using local fixtures only.',
      kpis: <MockAnalyticsKpi>[
        MockAnalyticsKpi(
          label: 'Avg. Score',
          value: '${averageScore.toStringAsFixed(1)}%',
          deltaLabel: '+4.2 this week',
          tone: 'primary',
        ),
        MockAnalyticsKpi(
          label: 'Attendance',
          value:
              '${(_students.fold<int>(0, (sum, item) => sum + item.attendanceRate) / max(1, _students.length)).round()}%',
          deltaLabel: '+2 pts',
          tone: 'success',
        ),
        MockAnalyticsKpi(
          label: 'High Risk',
          value:
              '${_students.where((item) => item.riskLabel.toLowerCase().contains('risk')).length}',
          deltaLabel: 'Needs follow-up',
          tone: 'warning',
        ),
      ],
      activityTrend: const <MockAnalyticsPoint>[
        MockAnalyticsPoint(label: 'Sat', value: 46),
        MockAnalyticsPoint(label: 'Sun', value: 58),
        MockAnalyticsPoint(label: 'Mon', value: 64),
        MockAnalyticsPoint(label: 'Tue', value: 72),
        MockAnalyticsPoint(label: 'Wed', value: 69),
        MockAnalyticsPoint(label: 'Thu', value: 77),
      ],
      completionTrend: const <MockAnalyticsPoint>[
        MockAnalyticsPoint(label: 'W1', value: 52),
        MockAnalyticsPoint(label: 'W2', value: 61),
        MockAnalyticsPoint(label: 'W3', value: 67),
        MockAnalyticsPoint(label: 'W4', value: 74),
      ],
      subjectPulse: _subjects
          .map(
            (subject) => MockAnalyticsSubjectPulse(
              subjectCode: subject.code,
              subjectName: subject.name,
              healthScore: (subject.progress * 100).round() + 12,
              completionRate: (subject.progress * 100).round(),
              riskLabel: subject.progress >= 0.75
                  ? 'Healthy'
                  : subject.progress >= 0.6
                  ? 'Watch'
                  : 'Needs Attention',
            ),
          )
          .toList(growable: false),
    );
  }

  DashboardSnapshot dashboardFor(SessionUser user) {
    final subjects = subjectsFor(user);
    final lectures = lecturesFor(user);
    final quizzes = quizzesFor(user);
    final tasks = tasksFor(user);
    final unreadNotifications = unreadNotificationsFor(user);
    final analytics = analyticsFor(user);
    final averageScore = _results.isEmpty
        ? 0.0
        : _results.fold<double>(0, (sum, item) => sum + item.percentage) /
              _results.length;
    final riskStudents = studentsFor(user)
        .where((student) => student.riskLabel.toLowerCase().contains('risk'))
        .toList(growable: false);

    final topResults = [..._results]
      ..sort((left, right) => right.percentage.compareTo(left.percentage));

    return DashboardSnapshot.fromJson(<String, dynamic>{
      'header': {
        'user': {
          'id': user.id,
          'name': user.fullName,
          'role': user.roleType.toUpperCase(),
          'greeting': user.isAdmin
              ? 'Operational pulse is steady today'
              : 'Good morning, ${user.fullName.split(' ').first}',
          'subtitle': user.isDoctor
              ? 'You have ${lectures.length} lecture blocks, ${tasks.length} tasks, and $unreadNotifications fresh alerts.'
              : user.isAdmin
              ? 'Staff, courses, and notifications are all running from local mock fixtures.'
              : 'Section coordination is active across ${subjects.length} subjects today.',
          'departments': [
            (_accountForUser(user)?.department ?? 'Computer Science'),
          ],
          'academic_years': subjects
              .map((subject) => subject.academicTerm)
              .take(2)
              .toList(),
        },
        'notification_badge': unreadNotifications,
        'generated_at': DateTime(2026, 4, 22, 10, 30).toIso8601String(),
      },
      'quick_actions': [
        if (user.hasPermission('lectures.create'))
          {
            'id': 'qa-lecture',
            'label': 'Create lecture',
            'description': 'Draft the next lecture block and publish timing.',
            'route': AppRoutes.lectures,
            'permission': 'lectures.create',
            'icon': 'calendar',
            'tone': 'primary',
          },
        if (user.hasPermission('quizzes.create'))
          {
            'id': 'qa-quiz',
            'label': 'Create quiz',
            'description': 'Open a new assessment window for the current week.',
            'route': AppRoutes.quizzes,
            'permission': 'quizzes.create',
            'icon': 'quiz',
            'tone': 'secondary',
          },
        {
          'id': 'qa-results',
          'label': 'Review results',
          'description': 'Check the latest grading and publication status.',
          'route': AppRoutes.results,
          'permission': 'results.view',
          'icon': 'chart',
          'tone': 'success',
        },
      ],
      'action_center': {
        'summary':
            'Three work items need attention before the next delivery cycle.',
        'items': [
          {
            'id': 'action-1',
            'type': 'grading',
            'priority': 'HIGH',
            'title': 'Finalize pending grading',
            'explanation':
                '${tasks.length} assignment milestones still need publication or review.',
            'cta_label': 'Open results',
            'route': AppRoutes.results,
          },
          {
            'id': 'action-2',
            'type': 'alerts',
            'priority': 'MEDIUM',
            'title': 'Respond to unread alerts',
            'explanation':
                '$unreadNotifications alert items are still unread in the workspace.',
            'cta_label': 'Open alerts',
            'route': AppRoutes.notifications,
          },
        ],
      },
      'today_focus': {
        'headline':
            'Keep delivery smooth across lectures, tasks, and support threads.',
        'summary':
            'The frontend is now running against a realistic local academic fixture set, so every dashboard block remains interactive without backend dependencies.',
        'metrics': [
          {
            'label': 'Subjects',
            'value': '${subjects.length}',
            'tone': 'primary',
          },
          {
            'label': 'Live Quizzes',
            'value': '${quizzes.length}',
            'tone': 'secondary',
          },
          {
            'label': 'Uploads',
            'value': '${_uploads.length}',
            'tone': 'success',
          },
        ],
        'primary_action': {
          'id': 'focus-1',
          'type': 'manage',
          'priority': 'HIGH',
          'title': 'Open announcements',
          'explanation':
              'Review pinned updates and active group communication.',
          'cta_label': 'View announcements',
          'route': AppRoutes.announcements,
        },
      },
      'timeline': {
        'groups': [
          {
            'id': 'today',
            'label': 'Today',
            'items': _schedule
                .take(3)
                .map(
                  (event) => {
                    'id': event.id,
                    'type': event.type.name,
                    'title': event.title,
                    'subject_name': event.subject,
                    'when_label':
                        '${event.startAt.hour.toString().padLeft(2, '0')}:${event.startAt.minute.toString().padLeft(2, '0')} - ${event.endAt.hour.toString().padLeft(2, '0')}:${event.endAt.minute.toString().padLeft(2, '0')}',
                    'status': event.status.label,
                    'route': AppRoutes.schedule,
                  },
                )
                .toList(),
          },
        ],
      },
      'subjects_overview': {
        'summary':
            'Each subject reflects realistic cohort size, section load, and health indicators.',
        'items': subjects
            .map(
              (subject) => {
                'id': subject.id,
                'name': subject.name,
                'code': subject.code,
                'department': subject.department,
                'academic_year': subject.academicTerm,
                'batch': '2026',
                'student_count': subject.studentCount,
                'groups_count': subject.sections.length,
                'sections_count': subject.sectionCount,
                'health_score': (subject.progress * 100).round() + 10,
                'risk_level': subject.progress >= 0.75 ? 'LOW' : 'WATCH',
                'quick_actions': [
                  {
                    'label': 'Open',
                    'route': '${AppRoutes.subjects}/${subject.id}',
                  },
                  {'label': 'Announcements', 'route': AppRoutes.announcements},
                ],
              },
            )
            .toList(),
      },
      'students_attention': {
        'count': riskStudents.length,
        'items': riskStudents
            .map(
              (student) => {
                'student_id': _numericId(student.id),
                'name': student.name,
                'reason':
                    '${student.riskLabel} - attendance ${student.attendanceRate}%',
                'severity': 'HIGH',
                'cta_label': 'Review student',
                'route': AppRoutes.students,
                'details': [
                  '${student.subjectCode} / ${student.sectionLabel}',
                  'Engagement score ${student.engagementScore}',
                ],
                'last_seen': student.lastActiveAt.toIso8601String(),
              },
            )
            .toList(),
      },
      'student_activity_insights': {
        'summary':
            'Engagement and grading are derived from the same local student and result fixtures.',
        'active_students': _students
            .where((student) => student.engagementScore >= 70)
            .length,
        'inactive_students': _students
            .where((student) => student.engagementScore < 50)
            .length,
        'missing_submissions': 12,
        'new_comments': 9,
        'unread_messages': _messageThreads.fold<int>(
          0,
          (sum, thread) => sum + thread.unreadCount,
        ),
        'low_engagement_count': _students
            .where((student) => student.engagementScore < 60)
            .length,
        'engagement_rate': 78,
        'students_needing_attention': riskStudents.length,
        'items': riskStudents
            .map(
              (student) => {
                'student_id': _numericId(student.id),
                'name': student.name,
                'reason': 'Low activity trend this week',
                'severity': 'MEDIUM',
                'cta_label': 'Open students',
                'route': AppRoutes.students,
              },
            )
            .toList(),
      },
      'course_health': {
        'overall_score': 84,
        'status': 'HEALTHY',
        'summary':
            'Mock subject health remains strong, with two courses still needing follow-up.',
        'metrics': [
          {'label': 'Completion', 'value': '74%', 'tone': 'primary'},
          {'label': 'Attendance', 'value': '82%', 'tone': 'success'},
          {
            'label': 'Alerts',
            'value': '$unreadNotifications',
            'tone': 'warning',
          },
        ],
        'subjects': subjects
            .map(
              (subject) => {
                'subject_id': subject.id,
                'subject_name': subject.name,
                'score': (subject.progress * 100).round() + 10,
                'status': subject.progress >= 0.75 ? 'HEALTHY' : 'WATCH',
              },
            )
            .toList(),
      },
      'group_activity_feed': {
        'items': _groupPosts
            .map(
              (post) => {
                'id': post.id,
                'activity_type': 'post',
                'subject_name': post.subjectCode,
                'group_name': 'Course groups',
                'author_name': post.authorName,
                'content': post.body,
                'route': AppRoutes.announcements,
                'timestamp': post.createdAt.toIso8601String(),
              },
            )
            .toList(),
      },
      'notifications_preview': {
        'unread_count': unreadNotifications,
        'items': _notifications
            .take(3)
            .map(
              (item) => {
                'id': int.tryParse(item.id) ?? _numericId(item.id),
                'title': item.title,
                'body': item.body,
                'category': item.courseLabel,
                'route': AppRoutes.notifications,
                'time': DateTime(2026, 4, 22, 9, 0).toIso8601String(),
                'is_unread': !item.isRead,
              },
            )
            .toList(),
      },
      'pending_grading': {
        'can_manage': true,
        'count': tasks.length,
        'summary':
            'Assignments and quiz marks can be reviewed locally before real APIs are connected.',
        'items': _results
            .take(3)
            .map(
              (result) => {
                'task_id': _numericId(result.id),
                'title': result.assessmentTitle,
                'subject_name': result.subjectName,
                'pending_count': max(1, (100 - result.percentage).round()),
                'cta_label': 'Review',
                'route': AppRoutes.results,
              },
            )
            .toList(),
      },
      'performance_analytics': {
        'is_limited': false,
        'summary': analytics.summary,
        'average_score': double.parse(averageScore.toStringAsFixed(1)),
        'trend': analytics.activityTrend
            .map((point) => {'label': point.label, 'value': point.value})
            .toList(),
        'top_performers': topResults
            .take(3)
            .map(
              (result) => {
                'student_name': result.studentName,
                'average_score': result.percentage,
              },
            )
            .toList(),
        'low_performers': topResults.reversed
            .take(2)
            .map(
              (result) => {
                'student_name': result.studentName,
                'average_score': result.percentage,
              },
            )
            .toList(),
      },
      'risk_alerts': {
        'count': riskStudents.length,
        'items': riskStudents
            .map(
              (student) => {
                'id': student.id,
                'severity': 'HIGH',
                'title': '${student.name} needs follow-up',
                'explanation':
                    '${student.subjectCode} attendance is ${student.attendanceRate}% with engagement ${student.engagementScore}.',
                'cta_label': 'Open students',
                'route': AppRoutes.students,
              },
            )
            .toList(),
      },
      'weekly_summary': {
        'headline':
            'Frontend-only workspace is ready for realistic review cycles.',
        'items': [
          {'label': 'Subjects', 'value': '${subjects.length}'},
          {'label': 'Results', 'value': '${_results.length}'},
          {'label': 'Threads', 'value': '${_messageThreads.length}'},
        ],
      },
      'smart_suggestions': {
        'items': [
          {
            'id': 'suggest-1',
            'title': 'Open analytics before publishing the next task',
            'explanation':
                'The mock analytics page highlights low-engagement segments you may want to support.',
            'cta_label': 'View analytics',
            'route': AppRoutes.analytics,
          },
          {
            'id': 'suggest-2',
            'title': 'Pin a quick announcement for upcoming deadlines',
            'explanation':
                'Announcements and group posts are ready in the local workspace.',
            'cta_label': 'Open announcements',
            'route': AppRoutes.announcements,
          },
        ],
      },
    });
  }

  void _seed() {
    for (final accountMap in MockSamplePayloads.accounts) {
      final account = _MockAccount.fromJson(accountMap);
      _accountsByEmail[account.user.universityEmail.toLowerCase()] = account;
    }

    _subjects.addAll(
      MockSamplePayloads.teachingSubjects.map(_teachingSubjectFromJson),
    );
    _notifications.addAll(
      MockSamplePayloads.notifications.map(_workspaceNotificationFromJson),
    );
    _schedule.addAll(
      MockSamplePayloads.schedule.map(
        (item) => ScheduleEventItem.fromJson(Map<String, dynamic>.from(item)),
      ),
    );
    _uploads.addAll(
      MockSamplePayloads.uploads.map(
        (item) => UploadModel.fromJson(Map<String, dynamic>.from(item)),
      ),
    );
    _results.addAll(MockSamplePayloads.results.map(_resultFromJson));
    _announcements.addAll(
      MockSamplePayloads.announcements.map(_announcementFromJson),
    );
    _students.addAll(MockSamplePayloads.students.map(_studentFromJson));
    _groupPosts.addAll(MockSamplePayloads.groupPosts.map(_groupPostFromJson));
    _messageThreads.addAll(
      MockSamplePayloads.messageThreads.map(_messageThreadFromJson),
    );
    _departments.addAll(
      MockSamplePayloads.departments.map(
        (item) => DepartmentModel.fromJson(Map<String, dynamic>.from(item)),
      ),
    );
  }

  _MockAccount? _accountForUser(SessionUser user) {
    return _accountsByEmail[user.universityEmail.toLowerCase()];
  }

  TeachingSubject _subjectForPayload(String? value) {
    final needle = value?.trim().toLowerCase();
    if (needle == null || needle.isEmpty) {
      return _subjects.first;
    }

    return _subjects.firstWhere(
      (subject) =>
          subject.name.toLowerCase().contains(needle) ||
          subject.code.toLowerCase().contains(needle),
      orElse: () => _subjects.first,
    );
  }

  void _replaceSubject(TeachingSubject current, TeachingSubject next) {
    final index = _subjects.indexWhere((subject) => subject.id == current.id);
    if (index != -1) {
      _subjects[index] = next;
    }
  }

  TeachingSubject _cloneSubject(
    TeachingSubject source, {
    List<TeachingLecture>? lectures,
    List<TeachingSection>? sections,
    List<TeachingQuiz>? quizzes,
    List<TeachingTask>? tasks,
  }) {
    return TeachingSubject(
      id: source.id,
      code: source.code,
      name: source.name,
      department: source.department,
      academicTerm: source.academicTerm,
      description: source.description,
      studentCount: source.studentCount,
      sectionCount: source.sectionCount,
      progress: source.progress,
      accentColor: source.accentColor,
      lectures: lectures ?? source.lectures,
      sections: sections ?? source.sections,
      quizzes: quizzes ?? source.quizzes,
      tasks: tasks ?? source.tasks,
    );
  }

  TeachingLecture _copyLecture(
    TeachingLecture source, {
    String? id,
    String? title,
    String? audience,
    String? dayLabel,
    String? timeLabel,
    String? room,
    String? statusLabel,
    String? weekLabel,
    String? description,
    String? startsAtIso,
    String? endsAtIso,
    String? deliveryMode,
    String? meetingUrl,
    String? locationLabel,
    String? attachmentLabel,
    String? publisherName,
  }) {
    return TeachingLecture(
      id: id ?? source.id,
      title: title ?? source.title,
      audience: audience ?? source.audience,
      dayLabel: dayLabel ?? source.dayLabel,
      timeLabel: timeLabel ?? source.timeLabel,
      room: room ?? source.room,
      statusLabel: statusLabel ?? source.statusLabel,
      weekLabel: weekLabel ?? source.weekLabel,
      description: description ?? source.description,
      startsAtIso: startsAtIso ?? source.startsAtIso,
      endsAtIso: endsAtIso ?? source.endsAtIso,
      deliveryMode: deliveryMode ?? source.deliveryMode,
      meetingUrl: meetingUrl ?? source.meetingUrl,
      locationLabel: locationLabel ?? source.locationLabel,
      attachmentLabel: attachmentLabel ?? source.attachmentLabel,
      publisherName: publisherName ?? source.publisherName,
    );
  }

  TeachingSection _copySection(
    TeachingSection source, {
    String? id,
    String? title,
    String? assistantName,
    String? dayLabel,
    String? timeLabel,
    String? room,
    String? statusLabel,
    String? groupLabel,
    String? description,
    String? scheduledAtIso,
    int? durationMinutes,
    String? deliveryMode,
    String? locationLabel,
    String? meetingLink,
    String? notes,
    int? expectedStudents,
    bool? addedToSchedule,
    bool? sendNotification,
    String? attachmentName,
  }) {
    return TeachingSection(
      id: id ?? source.id,
      title: title ?? source.title,
      assistantName: assistantName ?? source.assistantName,
      dayLabel: dayLabel ?? source.dayLabel,
      timeLabel: timeLabel ?? source.timeLabel,
      room: room ?? source.room,
      statusLabel: statusLabel ?? source.statusLabel,
      groupLabel: groupLabel ?? source.groupLabel,
      description: description ?? source.description,
      scheduledAtIso: scheduledAtIso ?? source.scheduledAtIso,
      durationMinutes: durationMinutes ?? source.durationMinutes,
      deliveryMode: deliveryMode ?? source.deliveryMode,
      locationLabel: locationLabel ?? source.locationLabel,
      meetingLink: meetingLink ?? source.meetingLink,
      notes: notes ?? source.notes,
      expectedStudents: expectedStudents ?? source.expectedStudents,
      addedToSchedule: addedToSchedule ?? source.addedToSchedule,
      sendNotification: sendNotification ?? source.sendNotification,
      attachmentName: attachmentName ?? source.attachmentName,
    );
  }

  TeachingQuiz _copyQuiz(
    TeachingQuiz source, {
    String? id,
    String? title,
    String? windowLabel,
    String? statusLabel,
    String? attemptsLabel,
    String? scopeLabel,
    String? description,
    String? startAtIso,
    String? endAtIso,
    int? durationMinutes,
    int? attemptsAllowed,
    int? totalMarks,
    int? questionCount,
    String? audienceLabel,
    int? totalStudents,
    int? enteredStudents,
    int? completedStudents,
    double? passRate,
    double? averageScore,
    int? liveParticipants,
    String? attachmentName,
    List<TeachingQuizQuestion>? questions,
    List<TeachingQuizSubmission>? submissions,
  }) {
    return TeachingQuiz(
      id: id ?? source.id,
      title: title ?? source.title,
      windowLabel: windowLabel ?? source.windowLabel,
      statusLabel: statusLabel ?? source.statusLabel,
      attemptsLabel: attemptsLabel ?? source.attemptsLabel,
      scopeLabel: scopeLabel ?? source.scopeLabel,
      description: description ?? source.description,
      startAtIso: startAtIso ?? source.startAtIso,
      endAtIso: endAtIso ?? source.endAtIso,
      durationMinutes: durationMinutes ?? source.durationMinutes,
      attemptsAllowed: attemptsAllowed ?? source.attemptsAllowed,
      totalMarks: totalMarks ?? source.totalMarks,
      questionCount: questionCount ?? source.questionCount,
      audienceLabel: audienceLabel ?? source.audienceLabel,
      totalStudents: totalStudents ?? source.totalStudents,
      enteredStudents: enteredStudents ?? source.enteredStudents,
      completedStudents: completedStudents ?? source.completedStudents,
      passRate: passRate ?? source.passRate,
      averageScore: averageScore ?? source.averageScore,
      liveParticipants: liveParticipants ?? source.liveParticipants,
      attachmentName: attachmentName ?? source.attachmentName,
      questions: questions ?? source.questions,
      submissions: submissions ?? source.submissions,
    );
  }

  String _ownerNameForSubject(int subjectId) {
    final subject = subjectById(subjectId);
    if (subject.department == 'Computer Science') {
      return 'Dr. Salma Hassan';
    }
    if (subject.department == 'Information Systems') {
      return 'Dr. Khaled Mostafa';
    }
    return 'Dr. Hala Ezz';
  }

  String _roomFromNotes(String? notes) {
    final trimmed = notes?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return 'Room to be confirmed';
    }
    return trimmed.length > 32 ? '${trimmed.substring(0, 32)}...' : trimmed;
  }

  DateTime get _workspaceNow => DateTime(2026, 4, 23, 12);

  void _ensureSubjectGroupsSeeded() {
    if (_subjectPosts.isNotEmpty) {
      return;
    }

    for (final subject in _subjects) {
      final sourcePosts = _groupPosts
          .where((post) => post.subjectCode == subject.code)
          .toList(growable: false);
      _subjectPosts[subject.id] = sourcePosts
          .map((post) {
            final comments = List.generate(
              min(post.commentsCount, 3),
              (index) => GroupCommentModel(
                id: _nextCommentId++,
                postId: _numericId(post.id),
                authorName: index.isEven ? 'Teaching Assistant' : 'Student Representative',
                authorRole: index.isEven ? 'Assistant' : 'Student',
                message: index.isEven
                    ? 'Shared with the tutorial groups and synced to attendance notes.'
                    : 'Can the rubric be posted before the next session?',
                createdAt: post.createdAt.add(Duration(minutes: 18 * (index + 1))),
              ),
            );

            final title = post.body.length > 38
                ? post.body.substring(0, 38)
                : post.body;
            return GroupPostModel(
              id: _numericId(post.id),
              subjectId: subject.id,
              title: title.trim().isEmpty ? '${subject.code} update' : title,
              content: post.body,
              authorName: post.authorName,
              authorRole: post.authorName.toLowerCase().contains('dr.')
                  ? 'Doctor'
                  : 'Assistant',
              createdAt: post.createdAt,
              updatedAt: post.createdAt,
              type: 'announcement',
              priority: post.commentsCount > 4 ? 'high' : 'normal',
              isPinned: post.commentsCount > 5,
              comments: comments,
              commentsCount: comments.length,
              reactionsCount: post.reactionsCount,
              attachmentLabel: comments.length > 1 ? 'Attached brief.pdf' : null,
            );
          })
          .toList(growable: false)
        ..sort((left, right) {
          if (left.isPinned == right.isPinned) {
            return right.createdAt.compareTo(left.createdAt);
          }
          return left.isPinned ? -1 : 1;
        });
    }
  }

  void _ensureGradebookSeeded() {
    if (_gradesBySubject.isNotEmpty) {
      return;
    }

    for (final subject in _subjects) {
      final students = _students
          .where((student) => student.subjectCode == subject.code)
          .toList(growable: false);
      final subjectGrades = <String, Map<String, _StoredGrade>>{};
      for (final blueprint in _categoryBlueprintsFor(const SessionUser(
        id: 0,
        fullName: '',
        universityEmail: '',
        roleType: 'doctor',
        isActive: true,
        permissions: <String>[],
        notificationEnabled: true,
      ))) {
        final entries = <String, _StoredGrade>{};
        for (var index = 0; index < students.length; index++) {
          final student = students[index];
          final score = (blueprint.maxScore * (0.52 + ((index % 5) * 0.08)))
              .clamp(0, blueprint.maxScore)
              .toDouble();
          final statusLabel = index % 4 == 0
              ? 'Draft'
              : index % 7 == 0
              ? 'Needs review'
              : 'Published';
          entries[student.code] = _StoredGrade(
            score: double.parse(score.toStringAsFixed(1)),
            maxScore: blueprint.maxScore,
            note: index % 6 == 0 ? 'Check section attendance mismatch' : null,
            statusLabel: statusLabel,
          );
        }
        subjectGrades[blueprint.key] = entries;
      }
      _gradesBySubject[subject.id] = subjectGrades;
    }
  }

  List<_GradeCategoryBlueprint> _categoryBlueprintsFor(SessionUser user) {
    final items = <_GradeCategoryBlueprint>[
      const _GradeCategoryBlueprint('midterm', 'Midterm', 20),
      const _GradeCategoryBlueprint('quiz', 'Quiz', 10),
      const _GradeCategoryBlueprint('oral', 'Oral', 10),
      const _GradeCategoryBlueprint('sheets', 'Sheets / Assignments', 15),
      const _GradeCategoryBlueprint('attendance', 'Attendance', 5),
      const _GradeCategoryBlueprint('coursework', 'Coursework / Year work', 20),
      const _GradeCategoryBlueprint('final', 'Final', 40),
    ];
    return items;
  }

  List<String> _allowedCategoryKeys(SessionUser user) {
    if (user.isAdmin) {
      return const <String>[
        'midterm',
        'final',
        'quiz',
        'oral',
        'sheets',
        'attendance',
        'coursework',
      ];
    }
    if (user.isDoctor) {
      return const <String>['midterm'];
    }
    return const <String>[
      'quiz',
      'oral',
      'sheets',
      'attendance',
      'coursework',
    ];
  }

  DateTime _lectureScheduledAtFromPayload(Map<String, dynamic> payload) {
    final rawDate =
        payload['publish_date']?.toString() ??
        payload['date']?.toString() ??
        payload['publish_at']?.toString();
    final parsedDate = DateTime.tryParse(rawDate ?? '');
    if (parsedDate == null) {
      return _workspaceNow.add(const Duration(days: 1));
    }
    final rawTime =
        payload['publish_time']?.toString() ??
        payload['time_label']?.toString() ??
        '09:00';
    final time = _timeOfDayFromPayload(rawTime);
    if (time == null) {
      return parsedDate;
    }
    return DateTime(
      parsedDate.year,
      parsedDate.month,
      parsedDate.day,
      time.hour,
      time.minute,
    );
  }

  int _expectedStudentsForSectionSubject(TeachingSubject subject) {
    final sectionsCount = subject.sections.isEmpty
        ? 1
        : subject.sections.length;
    return (subject.studentCount / sectionsCount).ceil();
  }

  DateTime _sectionScheduledAtFromPayload(Map<String, dynamic> payload) {
    final raw =
        payload['scheduled_at']?.toString() ?? payload['date']?.toString();
    final parsed = DateTime.tryParse(raw ?? '');
    if (parsed != null) {
      final time = _timeOfDayFromPayload(payload['time_label']?.toString());
      if (time == null) {
        return parsed;
      }
      return DateTime(
        parsed.year,
        parsed.month,
        parsed.day,
        time.hour,
        time.minute,
      );
    }
    return _workspaceNow.add(const Duration(days: 2));
  }

  _MockTimeOfDay? _timeOfDayFromPayload(String? raw) {
    final value = raw?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }
    final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(value);
    if (match == null) {
      return null;
    }
    final hour = int.tryParse(match.group(1) ?? '');
    final minute = int.tryParse(match.group(2) ?? '');
    if (hour == null || minute == null) {
      return null;
    }
    return _MockTimeOfDay(hour, minute);
  }

  String _sectionStatusLabel({
    required DateTime scheduledAt,
    required bool publishImmediately,
    required bool saveAsDraft,
  }) {
    if (saveAsDraft || !publishImmediately) {
      return 'Draft';
    }
    final endAt = scheduledAt.add(const Duration(minutes: 90));
    if (_workspaceNow.isAfter(endAt)) {
      return 'Finished';
    }
    if (_workspaceNow.isAfter(scheduledAt)) {
      return 'Live';
    }
    return 'Published';
  }

  String _weekdayName(int weekday) {
    return switch (weekday) {
      DateTime.monday => 'Monday',
      DateTime.tuesday => 'Tuesday',
      DateTime.wednesday => 'Wednesday',
      DateTime.thursday => 'Thursday',
      DateTime.friday => 'Friday',
      DateTime.saturday => 'Saturday',
      _ => 'Sunday',
    };
  }

  String _timeRangeLabel(
    DateTime startAt,
    int durationMinutes, {
    required String fallback,
  }) {
    final endAt = startAt.add(Duration(minutes: durationMinutes));
    final startHour = startAt.hour.toString().padLeft(2, '0');
    final startMinute = startAt.minute.toString().padLeft(2, '0');
    final endHour = endAt.hour.toString().padLeft(2, '0');
    final endMinute = endAt.minute.toString().padLeft(2, '0');
    final value = '$startHour:$startMinute - $endHour:$endMinute';
    return value.trim().isEmpty ? fallback : value;
  }

  DateTime _quizStartAtFromPayload(Map<String, dynamic> payload) {
    final rawStart = payload['start_at']?.toString();
    final parsed = DateTime.tryParse(rawStart ?? '');
    if (parsed != null) {
      return parsed;
    }
    final rawDate =
        payload['date']?.toString() ?? payload['scheduled_at']?.toString();
    final parsedDate = DateTime.tryParse(rawDate ?? '');
    final time = _timeOfDayFromPayload(payload['start_time_label']?.toString());
    if (parsedDate != null && time != null) {
      return DateTime(
        parsedDate.year,
        parsedDate.month,
        parsedDate.day,
        time.hour,
        time.minute,
      );
    }
    return _workspaceNow.add(const Duration(days: 1, hours: 3));
  }

  DateTime _quizEndAtFromPayload(
    Map<String, dynamic> payload,
    DateTime startAt,
    int durationMinutes,
  ) {
    final parsed = DateTime.tryParse(payload['end_at']?.toString() ?? '');
    if (parsed != null) {
      return parsed;
    }
    return startAt.add(Duration(minutes: durationMinutes));
  }

  String _quizStatusLabel({
    required DateTime startAt,
    required DateTime endAt,
    required bool publishImmediately,
    required bool saveAsDraft,
  }) {
    if (saveAsDraft || !publishImmediately) {
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

  List<TeachingQuizQuestion> _quizQuestionsFromPayload(
    Map<String, dynamic> payload,
  ) {
    final questions = (payload['questions'] as List? ?? const [])
        .whereType<Map>()
        .map(
          (question) => TeachingQuizQuestion(
            id: question['id']?.toString() ?? 'question-${question.hashCode}',
            prompt: question['prompt']?.toString() ?? 'Untitled question',
            type: question['type']?.toString() ?? 'multiple_choice',
            options: (question['options'] as List? ?? const [])
                .map((item) => item.toString())
                .toList(growable: false),
            correctAnswers: (question['correct_answers'] as List? ?? const [])
                .map((item) => item.toString())
                .toList(growable: false),
            marks: (question['marks'] as num?)?.toInt() ?? 1,
            isRequired: question['is_required'] != false,
          ),
        )
        .toList(growable: false);
    return questions;
  }

  int _totalMarksFromPayload(
    Map<String, dynamic> payload,
    List<TeachingQuizQuestion> questions,
  ) {
    final explicit = (payload['total_marks'] as num?)?.toInt();
    if (explicit != null && explicit > 0) {
      return explicit;
    }
    if (questions.isEmpty) {
      return 10;
    }
    return questions.fold<int>(0, (sum, question) => sum + question.marks);
  }

  String _quizWindowLabel({
    required DateTime startAt,
    required DateTime endAt,
    required int durationMinutes,
  }) {
    final weekday = _weekdayName(startAt.weekday).substring(0, 3);
    final startHour = startAt.hour.toString().padLeft(2, '0');
    final startMinute = startAt.minute.toString().padLeft(2, '0');
    return '$weekday $startHour:$startMinute - $durationMinutes min';
  }

  String _quizAttemptsLabel({
    required String statusLabel,
    required int enteredStudents,
    required int totalStudents,
  }) {
    return statusLabel == 'Draft'
        ? 'Awaiting publish'
        : '$enteredStudents/$totalStudents attempts';
  }

  List<TeachingQuizSubmission> _quizSubmissionsFromPayload({
    required Map<String, dynamic> payload,
    required int totalStudents,
    required int enteredStudents,
    required int completedStudents,
  }) {
    final submissions = (payload['submissions'] as List? ?? const [])
        .whereType<Map>()
        .map(
          (submission) => TeachingQuizSubmission(
            studentName: submission['student_name']?.toString() ?? '',
            studentCode: submission['student_code']?.toString() ?? '',
            statusLabel: submission['status_label']?.toString() ?? 'Completed',
            score: (submission['score'] as num?)?.toDouble(),
            startedAtIso: submission['started_at']?.toString(),
            submittedAtIso: submission['submitted_at']?.toString(),
            progress: (submission['progress'] as num?)?.toDouble() ?? 1,
          ),
        )
        .toList(growable: false);
    if (submissions.isNotEmpty) {
      return submissions;
    }
    final generated = <TeachingQuizSubmission>[];
    for (var index = 0; index < completedStudents; index++) {
      generated.add(
        TeachingQuizSubmission(
          studentName: 'Student ${index + 1}',
          studentCode: '20260${(index + 1).toString().padLeft(3, '0')}',
          statusLabel: 'Completed',
          score: 5 + ((index * 3) % 16).toDouble(),
          startedAtIso: _workspaceNow
              .subtract(const Duration(hours: 2))
              .toIso8601String(),
          submittedAtIso: _workspaceNow
              .subtract(Duration(minutes: index * 3))
              .toIso8601String(),
          progress: 1,
        ),
      );
    }
    final inProgress = (enteredStudents - completedStudents).clamp(
      0,
      totalStudents,
    );
    for (var index = 0; index < inProgress; index++) {
      generated.add(
        TeachingQuizSubmission(
          studentName: 'Student ${completedStudents + index + 1}',
          studentCode:
              '20260${(completedStudents + index + 1).toString().padLeft(3, '0')}',
          statusLabel: 'In Progress',
          startedAtIso: _workspaceNow
              .subtract(Duration(minutes: 8 + (index * 4)))
              .toIso8601String(),
          progress: 0.35 + ((index % 3) * 0.15),
        ),
      );
    }
    final notStarted = (totalStudents - enteredStudents).clamp(
      0,
      totalStudents,
    );
    for (var index = 0; index < notStarted; index++) {
      generated.add(
        TeachingQuizSubmission(
          studentName: 'Student ${enteredStudents + index + 1}',
          studentCode:
              '20260${(enteredStudents + index + 1).toString().padLeft(3, '0')}',
          statusLabel: 'Not Started',
        ),
      );
    }
    return generated;
  }

  TeachingSubject _teachingSubjectFromJson(Map<String, dynamic> json) {
    return TeachingSubject(
      id: (json['id'] as num?)?.toInt() ?? 0,
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      academicTerm: json['academic_term']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      studentCount: (json['student_count'] as num?)?.toInt() ?? 0,
      sectionCount: (json['section_count'] as num?)?.toInt() ?? 0,
      progress: (json['progress'] as num?)?.toDouble() ?? 0,
      accentColor: Color((json['accent_color'] as num?)?.toInt() ?? 0xFF2563EB),
      lectures: (json['lectures'] as List? ?? const [])
          .map(
            (item) => TeachingLecture(
              id: item['id']?.toString() ?? '',
              title: item['title']?.toString() ?? '',
              audience: item['audience']?.toString() ?? '',
              dayLabel: item['day_label']?.toString() ?? '',
              timeLabel: item['time_label']?.toString() ?? '',
              room: item['room']?.toString() ?? '',
              statusLabel: item['status_label']?.toString() ?? '',
              weekLabel: item['week_label']?.toString() ?? '',
              description: item['description']?.toString(),
              startsAtIso: item['starts_at']?.toString(),
              endsAtIso: item['ends_at']?.toString(),
              deliveryMode: item['delivery_mode']?.toString(),
              meetingUrl: item['meeting_url']?.toString(),
              locationLabel: item['location_label']?.toString(),
              attachmentLabel: item['attachment_label']?.toString(),
              publisherName: item['publisher_name']?.toString(),
            ),
          )
          .toList(growable: false),
      sections: (json['sections'] as List? ?? const [])
          .map(
            (item) => TeachingSection(
              id: item['id']?.toString() ?? '',
              title: item['title']?.toString() ?? '',
              assistantName: item['assistant_name']?.toString() ?? '',
              dayLabel: item['day_label']?.toString() ?? '',
              timeLabel: item['time_label']?.toString() ?? '',
              room: item['room']?.toString() ?? '',
              statusLabel: item['status_label']?.toString() ?? '',
              groupLabel: item['group_label']?.toString() ?? '',
              description: item['description']?.toString(),
              scheduledAtIso: item['scheduled_at']?.toString(),
              durationMinutes: (item['duration_minutes'] as num?)?.toInt(),
              deliveryMode: item['delivery_mode']?.toString(),
              locationLabel: item['location_label']?.toString(),
              meetingLink: item['meeting_link']?.toString(),
              notes: item['notes']?.toString(),
              expectedStudents: (item['expected_students'] as num?)?.toInt(),
              addedToSchedule: item['add_to_schedule'] == true,
              sendNotification: item['send_notification'] == true,
              attachmentName: item['attachment_name']?.toString(),
            ),
          )
          .toList(growable: false),
      quizzes: (json['quizzes'] as List? ?? const [])
          .map(
            (item) => TeachingQuiz(
              id: item['id']?.toString() ?? '',
              title: item['title']?.toString() ?? '',
              windowLabel: item['window_label']?.toString() ?? '',
              statusLabel: item['status_label']?.toString() ?? '',
              attemptsLabel: item['attempts_label']?.toString() ?? '',
              scopeLabel: item['scope_label']?.toString() ?? '',
              description: item['description']?.toString(),
              startAtIso: item['start_at']?.toString(),
              endAtIso: item['end_at']?.toString(),
              durationMinutes: (item['duration_minutes'] as num?)?.toInt(),
              attemptsAllowed: (item['attempts_allowed'] as num?)?.toInt(),
              totalMarks: (item['total_marks'] as num?)?.toInt(),
              questionCount: (item['question_count'] as num?)?.toInt(),
              audienceLabel: item['audience_label']?.toString(),
              totalStudents: (item['total_students'] as num?)?.toInt(),
              enteredStudents: (item['entered_students'] as num?)?.toInt(),
              completedStudents: (item['completed_students'] as num?)?.toInt(),
              passRate: (item['pass_rate'] as num?)?.toDouble(),
              averageScore: (item['average_score'] as num?)?.toDouble(),
              liveParticipants: (item['live_participants'] as num?)?.toInt(),
              attachmentName: item['attachment_name']?.toString(),
              questions: (item['questions'] as List? ?? const [])
                  .whereType<Map>()
                  .map(
                    (question) => TeachingQuizQuestion(
                      id: question['id']?.toString() ?? '',
                      prompt: question['prompt']?.toString() ?? '',
                      type: question['type']?.toString() ?? 'multiple_choice',
                      options: (question['options'] as List? ?? const [])
                          .map((option) => option.toString())
                          .toList(growable: false),
                      correctAnswers:
                          (question['correct_answers'] as List? ?? const [])
                              .map((answer) => answer.toString())
                              .toList(growable: false),
                      marks: (question['marks'] as num?)?.toInt() ?? 1,
                      isRequired: question['is_required'] != false,
                    ),
                  )
                  .toList(growable: false),
              submissions: (item['submissions'] as List? ?? const [])
                  .whereType<Map>()
                  .map(
                    (submission) => TeachingQuizSubmission(
                      studentName: submission['student_name']?.toString() ?? '',
                      studentCode: submission['student_code']?.toString() ?? '',
                      statusLabel: submission['status_label']?.toString() ?? '',
                      score: (submission['score'] as num?)?.toDouble(),
                      startedAtIso: submission['started_at']?.toString(),
                      submittedAtIso: submission['submitted_at']?.toString(),
                      progress:
                          (submission['progress'] as num?)?.toDouble() ?? 0,
                    ),
                  )
                  .toList(growable: false),
            ),
          )
          .toList(growable: false),
      tasks: (json['tasks'] as List? ?? const [])
          .map(
            (item) => TeachingTask(
              id: item['id']?.toString() ?? '',
              title: item['title']?.toString() ?? '',
              deadlineLabel: item['deadline_label']?.toString() ?? '',
              statusLabel: item['status_label']?.toString() ?? '',
              progressLabel: item['progress_label']?.toString() ?? '',
              scopeLabel: item['scope_label']?.toString() ?? '',
            ),
          )
          .toList(growable: false),
    );
  }

  WorkspaceNotificationItem _workspaceNotificationFromJson(
    Map<String, dynamic> json,
  ) {
    final category = json['category']?.toString() ?? '';
    return WorkspaceNotificationItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      timeLabel: _relativeTime(_dateTime(json['created_at'])),
      statusLabel: json['status_label']?.toString() ?? '',
      courseLabel: json['course_label']?.toString() ?? '',
      isRead: json['is_read'] == true,
      icon: switch (category) {
        'schedule' => Icons.meeting_room_rounded,
        'quiz' => Icons.quiz_rounded,
        'attendance' => Icons.check_circle_outline_rounded,
        'task' => Icons.assignment_late_rounded,
        _ => Icons.notifications_active_rounded,
      },
    );
  }

  MockStudentResult _resultFromJson(Map<String, dynamic> json) {
    return MockStudentResult(
      id: json['id']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? '',
      studentCode: json['student_code']?.toString() ?? '',
      subjectCode: json['subject_code']?.toString() ?? '',
      subjectName: json['subject_name']?.toString() ?? '',
      assessmentTitle: json['assessment_title']?.toString() ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0,
      maxScore: (json['max_score'] as num?)?.toDouble() ?? 0,
      statusLabel: json['status_label']?.toString() ?? '',
      updatedAt: _dateTime(json['updated_at']),
    );
  }

  MockAnnouncementItem _announcementFromJson(Map<String, dynamic> json) {
    return MockAnnouncementItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      subjectCode: json['subject_code']?.toString() ?? '',
      audienceLabel: json['audience_label']?.toString() ?? '',
      priorityLabel: json['priority_label']?.toString() ?? '',
      isPinned: json['is_pinned'] == true,
      publishedAt: _dateTime(json['published_at']),
      authorName: json['author_name']?.toString() ?? '',
    );
  }

  MockStudentDirectoryEntry _studentFromJson(Map<String, dynamic> json) {
    return MockStudentDirectoryEntry(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      subjectCode: json['subject_code']?.toString() ?? '',
      sectionLabel: json['section_label']?.toString() ?? '',
      attendanceRate: (json['attendance_rate'] as num?)?.toInt() ?? 0,
      averageScore: (json['average_score'] as num?)?.toDouble() ?? 0,
      engagementScore: (json['engagement_score'] as num?)?.toInt() ?? 0,
      riskLabel: json['risk_label']?.toString() ?? '',
      lastActiveAt: _dateTime(json['last_active_at']),
    );
  }

  MockGroupPost _groupPostFromJson(Map<String, dynamic> json) {
    return MockGroupPost(
      id: json['id']?.toString() ?? '',
      subjectCode: json['subject_code']?.toString() ?? '',
      authorName: json['author_name']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      reactionsCount: (json['reactions_count'] as num?)?.toInt() ?? 0,
      commentsCount: (json['comments_count'] as num?)?.toInt() ?? 0,
      createdAt: _dateTime(json['created_at']),
    );
  }

  MockMessageThread _messageThreadFromJson(Map<String, dynamic> json) {
    return MockMessageThread(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      participantsLabel: json['participants_label']?.toString() ?? '',
      lastMessage: json['last_message']?.toString() ?? '',
      unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
      updatedAt: _dateTime(json['updated_at']),
    );
  }

  int _numericId(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? raw.hashCode.abs();
  }

  int _weekNumber(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 1;
  }

  DateTime _dateTime(Object? raw) {
    return DateTime.tryParse(raw?.toString() ?? '') ?? DateTime(2026, 4, 22);
  }

  String _relativeTime(DateTime dateTime) {
    final difference = DateTime(2026, 4, 22, 10, 30).difference(dateTime);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    }
    return '${difference.inDays} day ago';
  }
}

class _MockAccount {
  const _MockAccount({
    required this.user,
    required this.password,
    required this.department,
    required this.officeHours,
    required this.locationLabel,
    required this.focusAreas,
  });

  final SessionUser user;
  final String password;
  final String department;
  final String officeHours;
  final String locationLabel;
  final List<String> focusAreas;

  factory _MockAccount.fromJson(Map<String, dynamic> json) {
    return _MockAccount(
      user: SessionUser.fromJson(json),
      password: json['password']?.toString() ?? '',
      department: json['department']?.toString() ?? 'Computer Science',
      officeHours:
          json['office_hours']?.toString() ?? 'Sun - Thu, 09:00 - 15:00',
      locationLabel: json['location_label']?.toString() ?? 'Campus Office',
      focusAreas: (json['focus_areas'] as List? ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
    );
  }

  _MockAccount copyWith({
    SessionUser? user,
    String? locationLabel,
    String? officeHours,
  }) {
    return _MockAccount(
      user: user ?? this.user,
      password: password,
      department: department,
      officeHours: officeHours ?? this.officeHours,
      locationLabel: locationLabel ?? this.locationLabel,
      focusAreas: focusAreas,
    );
  }
}

class _MockTimeOfDay {
  const _MockTimeOfDay(this.hour, this.minute);

  final int hour;
  final int minute;
}

class _GradeCategoryBlueprint {
  const _GradeCategoryBlueprint(this.key, this.label, this.maxScore);

  final String key;
  final String label;
  final double maxScore;
}

class _StoredGrade {
  const _StoredGrade({
    required this.score,
    required this.maxScore,
    required this.statusLabel,
    this.note,
  });

  final double? score;
  final double maxScore;
  final String statusLabel;
  final String? note;
}
