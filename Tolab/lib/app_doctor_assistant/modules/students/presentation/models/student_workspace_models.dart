import 'package:flutter/material.dart';

import '../../../../core/models/session_user.dart';
import '../../../../mock/doctor_assistant_mock_repository.dart';
import '../../../../mock/mock_portal_models.dart';

class StudentsWorkspaceData {
  const StudentsWorkspaceData({
    required this.students,
    required this.summary,
  });

  final List<StudentWorkspaceItem> students;
  final List<StudentWorkspaceSummaryItem> summary;
}

class StudentWorkspaceSummaryItem {
  const StudentWorkspaceSummaryItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

class StudentWorkspaceItem {
  const StudentWorkspaceItem({
    required this.id,
    required this.name,
    required this.code,
    required this.subjectId,
    required this.subjectName,
    required this.subjectCode,
    required this.sectionLabel,
    required this.attendanceRate,
    required this.averageScore,
    required this.engagementScore,
    required this.riskLabel,
    required this.lastActiveLabel,
    required this.completedQuizzes,
    required this.completedSheets,
    required this.academicNotes,
    required this.isFlagged,
  });

  final String id;
  final String name;
  final String code;
  final int subjectId;
  final String subjectName;
  final String subjectCode;
  final String sectionLabel;
  final int attendanceRate;
  final double averageScore;
  final int engagementScore;
  final String riskLabel;
  final String lastActiveLabel;
  final int completedQuizzes;
  final int completedSheets;
  final List<String> academicNotes;
  final bool isFlagged;
}

class StudentDetailsData {
  const StudentDetailsData({
    required this.student,
    required this.gradeRows,
    required this.lastActivity,
    required this.quizCompletionLabel,
    required this.sheetCompletionLabel,
    required this.attendanceInsight,
    required this.performanceInsight,
  });

  final StudentWorkspaceItem student;
  final List<StudentGradeLine> gradeRows;
  final String lastActivity;
  final String quizCompletionLabel;
  final String sheetCompletionLabel;
  final String attendanceInsight;
  final String performanceInsight;
}

class StudentGradeLine {
  const StudentGradeLine({
    required this.label,
    required this.scoreLabel,
    required this.statusLabel,
  });

  final String label;
  final String scoreLabel;
  final String statusLabel;
}

StudentsWorkspaceData buildStudentsWorkspace(
  DoctorAssistantMockRepository repository,
  SessionUser user, {
  Map<String, List<String>> notesByStudentCode = const <String, List<String>>{},
  Set<String> flaggedStudentCodes = const <String>{},
}) {
  final rawStudents = repository.studentsFor(user);
  final items = rawStudents
      .map(
        (student) => _buildStudentItem(
          repository: repository,
          user: user,
          student: student,
          notes: notesByStudentCode[student.code] ?? const <String>[],
          isFlagged: flaggedStudentCodes.contains(student.code),
        ),
      )
      .toList(growable: false);

  return StudentsWorkspaceData(
    students: items,
    summary: [
      StudentWorkspaceSummaryItem(
        label: 'Students monitored',
        value: '${items.length}',
        icon: Icons.groups_rounded,
        color: const Color(0xFF2563EB),
      ),
      StudentWorkspaceSummaryItem(
        label: 'High risk',
        value:
            '${items.where((student) => student.riskLabel.toLowerCase() == 'high risk').length}',
        icon: Icons.warning_amber_rounded,
        color: const Color(0xFFDC2626),
      ),
      StudentWorkspaceSummaryItem(
        label: 'Attendance below 80%',
        value: '${items.where((student) => student.attendanceRate < 80).length}',
        icon: Icons.how_to_reg_rounded,
        color: const Color(0xFFF59E0B),
      ),
      StudentWorkspaceSummaryItem(
        label: 'Flagged',
        value: '${items.where((student) => student.isFlagged).length}',
        icon: Icons.outlined_flag_rounded,
        color: const Color(0xFF7C3AED),
      ),
    ],
  );
}

StudentDetailsData buildStudentDetails(
  DoctorAssistantMockRepository repository,
  SessionUser user,
  StudentWorkspaceItem student,
) {
  final results = repository.subjectResultsById(student.subjectId, user);
  final row = results.students
      .where((item) => item.studentCode == student.code)
      .firstOrNull;
  final categories = results.categories;

  final gradeRows = categories
      .map(
        (category) {
          final entry = row?.entries[category.key];
          final rawScore = entry?.score;
          return StudentGradeLine(
            label: category.label,
            scoreLabel: rawScore == null
                ? 'Pending'
                : '${rawScore.toStringAsFixed(1)} / ${entry?.maxScore.toStringAsFixed(0) ?? category.maxScore.toStringAsFixed(0)}',
            statusLabel: entry?.statusLabel ?? category.statusLabel,
          );
        },
      )
      .toList(growable: false);

  return StudentDetailsData(
    student: student,
    gradeRows: gradeRows,
    lastActivity: student.lastActiveLabel,
    quizCompletionLabel: '${student.completedQuizzes} completed quiz flows',
    sheetCompletionLabel: '${student.completedSheets} section / sheet activities in rhythm',
    attendanceInsight: student.attendanceRate >= 85
        ? 'Attendance is healthy and inside the course policy band.'
        : 'Attendance needs closer tracking before the next graded milestone.',
    performanceInsight: student.averageScore >= 75
        ? 'Performance is stable enough for standard follow-up.'
        : 'Performance trend suggests intervention, note logging, or direct outreach.',
  );
}

List<StudentWorkspaceItem> filterStudentsWorkspace(
  List<StudentWorkspaceItem> items, {
  required String searchQuery,
  required String riskFilter,
  required String attendanceFilter,
  required String scoreFilter,
  required String engagementFilter,
}) {
  return items.where((student) {
    final matchesSearch = searchQuery.isEmpty ||
        student.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
        student.code.toLowerCase().contains(searchQuery.toLowerCase()) ||
        student.subjectCode.toLowerCase().contains(searchQuery.toLowerCase());
    final matchesRisk = riskFilter == 'All' || student.riskLabel == riskFilter;
    final matchesAttendance = switch (attendanceFilter) {
      'Below 80%' => student.attendanceRate < 80,
      '80%+' => student.attendanceRate >= 80,
      _ => true,
    };
    final matchesScore = switch (scoreFilter) {
      'Below 60' => student.averageScore < 60,
      '60 - 79' => student.averageScore >= 60 && student.averageScore < 80,
      '80+' => student.averageScore >= 80,
      _ => true,
    };
    final matchesEngagement = switch (engagementFilter) {
      'Below 60' => student.engagementScore < 60,
      '60+' => student.engagementScore >= 60,
      _ => true,
    };

    return matchesSearch &&
        matchesRisk &&
        matchesAttendance &&
        matchesScore &&
        matchesEngagement;
  }).toList(growable: false);
}

StudentWorkspaceItem _buildStudentItem({
  required DoctorAssistantMockRepository repository,
  required SessionUser user,
  required MockStudentDirectoryEntry student,
  required List<String> notes,
  required bool isFlagged,
}) {
  final subject = repository
      .subjectsFor(user)
      .where((item) => item.code == student.subjectCode)
      .firstOrNull;
  final results = subject == null
      ? null
      : repository.subjectResultsById(subject.id, user);
  final resultRow = results?.students
      .where((row) => row.studentCode == student.code)
      .firstOrNull;
  final completedQuizzes = resultRow?.entries.values
          .where((entry) => entry.statusLabel.toLowerCase() == 'published')
          .length ??
      0;

  return StudentWorkspaceItem(
    id: student.id,
    name: student.name,
    code: student.code,
    subjectId: subject?.id ?? 0,
    subjectName: subject?.name ?? student.subjectCode,
    subjectCode: student.subjectCode,
    sectionLabel: student.sectionLabel,
    attendanceRate: student.attendanceRate,
    averageScore: student.averageScore,
    engagementScore: student.engagementScore,
    riskLabel: student.riskLabel,
    lastActiveLabel: _relativeTime(student.lastActiveAt),
    completedQuizzes: completedQuizzes,
    completedSheets: subject?.sections.length ?? 0,
    academicNotes: notes,
    isFlagged: isFlagged,
  );
}

String _relativeTime(DateTime value) {
  final difference = DateTime(2026, 4, 23, 12).difference(value);
  if (difference.inHours < 1) {
    return '${difference.inMinutes}m ago';
  }
  if (difference.inDays < 1) {
    return '${difference.inHours}h ago';
  }
  return '${difference.inDays}d ago';
}
