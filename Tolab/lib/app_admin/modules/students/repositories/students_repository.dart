import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

import '../models/student_management_models.dart';
import '../services/students_api_service.dart';

class StudentsRepository {
  StudentsRepository(this._apiService) : _snapshot = _buildSeedSnapshot();

  final StudentsApiService _apiService;
  StudentModuleSnapshot _snapshot;

  Future<StudentModuleSnapshot> fetchModuleSnapshot({
    bool forceRefresh = false,
  }) async {
    if (forceRefresh) {
      try {
        _snapshot = await _apiService.fetchModuleSnapshot();
      } catch (_) {}
    }
    await Future<void>.delayed(const Duration(milliseconds: 220));
    return _snapshot;
  }

  Future<StudentProfile> saveStudent(
    StudentProfile student, {
    String? verificationCode,
  }) async {
    final isNew = student.id.isEmpty;
    final nextStudent = isNew
        ? student.copyWith(
            id: 'stu_${DateTime.now().microsecondsSinceEpoch}',
            studentNumber: student.studentNumber.isEmpty
                ? 'ST-${2000 + _snapshot.students.length}'
                : student.studentNumber,
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
          )
        : student;

    final students = [..._snapshot.students];
    final index = students.indexWhere((item) => item.id == nextStudent.id);
    if (index >= 0) {
      students[index] = nextStudent;
    } else {
      students.add(nextStudent);
    }
    _snapshot = _snapshot.copyWith(
      students: _sortStudents(students),
      alerts: [
        _alert(
          title: isNew
              ? 'New student profile added'
              : 'Student profile updated',
          body: '${nextStudent.fullName} is synced with the admin registry.',
          severity: StudentAlertSeverity.success,
          badgeLabel: 'Profile',
        ),
        ..._snapshot.alerts.take(5),
      ],
      generatedAt: DateTime.now(),
    );

    try {
      await _apiService.saveStudent(
        nextStudent,
        verificationCode: verificationCode,
      );
    } catch (_) {}

    return nextStudent;
  }

  Future<StudentModuleSnapshot> performBulkAction({
    required StudentBulkActionType type,
    required List<String> studentIds,
    String? courseTitle,
    StudentEnrollmentStatus? status,
    String? verificationCode,
  }) async {
    final students = [..._snapshot.students];
    final timestamp = DateTime.now();

    for (var index = 0; index < students.length; index++) {
      final student = students[index];
      if (!studentIds.contains(student.id)) continue;

      switch (type) {
        case StudentBulkActionType.approveRegistrations:
          students[index] = student.copyWith(
            enrollmentStatus: StudentEnrollmentStatus.active,
            registrationApproved: true,
            activities: [
              _activity(
                id: '${student.id}-approval-${timestamp.microsecondsSinceEpoch}',
                studentId: student.id,
                type: StudentActivityType.approval,
                title: 'Registration approved',
                description: 'Admin approved the enrollment package.',
                occurredAt: timestamp,
              ),
              ...student.activities,
            ],
          );
        case StudentBulkActionType.rejectRegistrations:
          students[index] = student.copyWith(
            enrollmentStatus: StudentEnrollmentStatus.suspended,
            registrationApproved: false,
            activities: [
              _activity(
                id: '${student.id}-rejected-${timestamp.microsecondsSinceEpoch}',
                studentId: student.id,
                type: StudentActivityType.approval,
                title: 'Registration rejected',
                description: 'Admin rejected the registration package.',
                occurredAt: timestamp,
              ),
              ...student.activities,
            ],
          );
        case StudentBulkActionType.assignCourse:
          final normalizedCourse = courseTitle?.trim();
          if (normalizedCourse == null || normalizedCourse.isEmpty) continue;
          final alreadyExists = student.courses.any(
            (item) =>
                item.title.toLowerCase() == normalizedCourse.toLowerCase() &&
                item.isCurrentTerm,
          );
          if (alreadyExists) continue;
          students[index] = student.copyWith(
            courses: [
              StudentCourseGrade(
                id: '${student.id}-${normalizedCourse.hashCode}',
                code: _courseCode(normalizedCourse),
                title: normalizedCourse,
                instructor: 'Assigned by Admin',
                semester: 'Spring 2026',
                credits: 3,
                score: 0,
                grade: 'In progress',
                attendanceRate: 0,
                status: 'Assigned',
              ),
              ...student.courses,
            ],
            activities: [
              _activity(
                id: '${student.id}-course-${timestamp.microsecondsSinceEpoch}',
                studentId: student.id,
                type: StudentActivityType.approval,
                title: 'Course assigned',
                description: '$normalizedCourse added from bulk action.',
                occurredAt: timestamp,
                courseTitle: normalizedCourse,
              ),
              ...student.activities,
            ],
          );
        case StudentBulkActionType.updateStatus:
          if (status == null) continue;
          students[index] = student.copyWith(enrollmentStatus: status);
      }
    }

    _snapshot = _snapshot.copyWith(
      students: _sortStudents(students),
      alerts: [
        _alert(
          title: type.label,
          body: '${studentIds.length} students processed successfully.',
          severity: StudentAlertSeverity.info,
          badgeLabel: 'Bulk action',
        ),
        ..._snapshot.alerts.take(5),
      ],
      generatedAt: timestamp,
    );

    try {
      await _apiService.performBulkAction(
        actionType: type,
        studentIds: studentIds,
        courseTitle: courseTitle,
        status: status,
        verificationCode: verificationCode,
      );
    } catch (_) {}

    return _snapshot;
  }

  Future<StudentModuleSnapshot> uploadDocuments(
    String studentId,
    List<StudentUploadedFile> files,
  ) async {
    final students = [..._snapshot.students];
    final studentIndex = students.indexWhere((item) => item.id == studentId);
    if (studentIndex < 0) return _snapshot;

    final student = students[studentIndex];
    final uploadedAt = DateTime.now();
    final newDocuments = [
      for (final file in files)
        StudentDocumentRecord(
          id: '${studentId}-${file.name.hashCode}-${uploadedAt.millisecondsSinceEpoch}',
          name: file.name,
          category: 'Uploaded file',
          status: StudentDocumentStatus.pending,
          uploadedAt: uploadedAt,
          sizeLabel: _formatFileSize(file.sizeInBytes),
          notes: 'Awaiting admin review.',
          localBytes: file.bytes,
          mimeType: file.mimeType,
        ),
    ];

    students[studentIndex] = student.copyWith(
      documents: [...newDocuments, ...student.documents],
      activities: [
        _activity(
          id: '${student.id}-document-${uploadedAt.microsecondsSinceEpoch}',
          studentId: student.id,
          type: StudentActivityType.document,
          title: 'Documents uploaded',
          description: '${files.length} new files added to the record.',
          occurredAt: uploadedAt,
        ),
        ...student.activities,
      ],
    );

    _snapshot = _snapshot.copyWith(
      students: students,
      alerts: [
        _alert(
          title: 'Documents awaiting approval',
          body: '${student.fullName} uploaded ${files.length} new documents.',
          severity: StudentAlertSeverity.warning,
          badgeLabel: 'Documents',
        ),
        ..._snapshot.alerts.take(5),
      ],
      generatedAt: uploadedAt,
    );

    try {
      await _apiService.uploadDocuments(studentId, files);
    } catch (_) {}

    return _snapshot;
  }

  Future<StudentModuleSnapshot> updateDocumentStatus({
    required String studentId,
    required String documentId,
    required StudentDocumentStatus status,
    String? verificationCode,
  }) async {
    final students = [..._snapshot.students];
    final studentIndex = students.indexWhere((item) => item.id == studentId);
    if (studentIndex < 0) return _snapshot;

    final student = students[studentIndex];
    students[studentIndex] = student.copyWith(
      documents: [
        for (final document in student.documents)
          if (document.id == documentId)
            document.copyWith(status: status)
          else
            document,
      ],
      activities: [
        _activity(
          id: '${student.id}-doc-status-${DateTime.now().microsecondsSinceEpoch}',
          studentId: student.id,
          type: StudentActivityType.approval,
          title: 'Document ${status.label.toLowerCase()}',
          description: 'Student document review completed.',
          occurredAt: DateTime.now(),
        ),
        ...student.activities,
      ],
    );
    _snapshot = _snapshot.copyWith(
      students: students,
      generatedAt: DateTime.now(),
    );

    try {
      await _apiService.updateDocumentStatus(
        studentId: studentId,
        documentId: documentId,
        status: status,
        verificationCode: verificationCode,
      );
    } catch (_) {}

    return _snapshot;
  }

  Future<StudentModuleSnapshot> sendCampaign({
    required String title,
    required String body,
    required StudentCommunicationChannel channel,
    required List<String> recipientStudentIds,
    String? audienceLabel,
    String? groupId,
  }) async {
    final sentAt = DateTime.now();
    final campaign = StudentMessageCampaign(
      id: 'campaign-${sentAt.microsecondsSinceEpoch}',
      title: title,
      body: body,
      audienceLabel: audienceLabel ?? 'Selected students',
      channel: channel,
      sentAt: sentAt,
      recipients: recipientStudentIds.length,
      delivered: recipientStudentIds.length,
      opened: max(1, recipientStudentIds.length ~/ 2),
      recipientStudentIds: recipientStudentIds,
      groupId: groupId,
    );

    _snapshot = _snapshot.copyWith(
      campaigns: [campaign, ..._snapshot.campaigns],
      alerts: [
        _alert(
          title: 'Campaign sent',
          body: '$title delivered to ${recipientStudentIds.length} students.',
          severity: StudentAlertSeverity.success,
          badgeLabel: channel.label,
        ),
        ..._snapshot.alerts.take(5),
      ],
      generatedAt: sentAt,
    );

    try {
      await _apiService.sendCampaign(
        title: title,
        body: body,
        channel: channel,
        recipientStudentIds: recipientStudentIds,
        audienceLabel: audienceLabel,
        groupId: groupId,
      );
    } catch (_) {}

    return _snapshot;
  }

  Future<StudentImportPreview> previewImport(
    String fileName,
    Uint8List bytes,
  ) async {
    final tabularRows = _readSpreadsheetRows(fileName, bytes);
    if (tabularRows.length < 2) {
      return StudentImportPreview(
        fileName: fileName,
        headers: const [],
        rows: const [],
        columnMapping: {
          for (final field in StudentImportField.values) field: null,
        },
        duplicates: const [],
        invalidRows: 0,
        validRows: 0,
      );
    }

    final headers = tabularRows.first
        .map((cell) => cell.trim())
        .where((cell) => cell.isNotEmpty)
        .toList(growable: false);
    final rows = [
      for (final rawRow in tabularRows.skip(1))
        {
          for (var index = 0; index < headers.length; index++)
            headers[index]: index < rawRow.length ? rawRow[index].trim() : '',
        },
    ];
    final mapping = _autoMapColumns(headers);

    var invalidRows = 0;
    final duplicates = <String>[];
    final existingIds = _snapshot.students
        .map((item) => item.studentNumber.toLowerCase())
        .toSet();
    final existingEmails = _snapshot.students
        .map((item) => item.contact.email.toLowerCase())
        .toSet();
    final fileSeen = <String>{};

    for (final row in rows) {
      final id = row[mapping[StudentImportField.studentId] ?? ''] ?? '';
      final email = row[mapping[StudentImportField.email] ?? ''] ?? '';
      final name = row[mapping[StudentImportField.fullName] ?? ''] ?? '';

      if (id.isEmpty || email.isEmpty || name.isEmpty) {
        invalidRows++;
      }
      final duplicateKey = '${id.toLowerCase()}|${email.toLowerCase()}';
      if (existingIds.contains(id.toLowerCase()) ||
          existingEmails.contains(email.toLowerCase()) ||
          fileSeen.contains(duplicateKey)) {
        duplicates.add(name.isEmpty ? id : '$name ($id)');
      }
      fileSeen.add(duplicateKey);
    }

    return StudentImportPreview(
      fileName: fileName,
      headers: headers,
      rows: rows,
      columnMapping: mapping,
      duplicates: duplicates,
      invalidRows: invalidRows,
      validRows: max(0, rows.length - invalidRows - duplicates.length),
    );
  }

  Future<({StudentModuleSnapshot snapshot, StudentImportResult result})>
  importStudents(
    StudentImportPreview preview, {
    void Function(double progress)? onProgress,
  }) async {
    final mappedRows = _rowsFromPreview(preview);
    final students = [..._snapshot.students];
    var imported = 0;
    var duplicateCount = 0;
    var failed = 0;
    final existingIds = students.map((item) => item.studentNumber).toSet();
    final existingEmails = students.map((item) => item.contact.email).toSet();

    for (var index = 0; index < mappedRows.length; index++) {
      final row = mappedRows[index];
      await Future<void>.delayed(const Duration(milliseconds: 110));
      onProgress?.call((index + 1) / max(1, mappedRows.length));

      final studentNumber = row.studentNumber.trim();
      final email = row.contact.email.trim();
      if (studentNumber.isEmpty ||
          email.isEmpty ||
          row.fullName.trim().isEmpty) {
        failed++;
        continue;
      }
      if (existingIds.contains(studentNumber) ||
          existingEmails.contains(email)) {
        duplicateCount++;
        continue;
      }
      students.add(row);
      existingIds.add(studentNumber);
      existingEmails.add(email);
      imported++;
    }

    _snapshot = _snapshot.copyWith(
      students: _sortStudents(students),
      alerts: [
        _alert(
          title: 'Bulk upload completed',
          body:
              '$imported students imported, $duplicateCount duplicates skipped.',
          severity: StudentAlertSeverity.success,
          badgeLabel: 'Import',
        ),
        ..._snapshot.alerts.take(5),
      ],
      generatedAt: DateTime.now(),
    );

    final result = StudentImportResult(
      imported: imported,
      duplicates: duplicateCount,
      failed: failed,
      summary:
          '$imported students imported, $duplicateCount duplicates skipped, $failed invalid rows ignored.',
    );

    return (snapshot: _snapshot, result: result);
  }

  Future<Uint8List> buildTranscriptPdf(String studentId) async {
    final student = _snapshot.findStudent(studentId);
    if (student == null) return Uint8List(0);

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) => [
          pw.Text(
            'Tolab Academy Transcript',
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Text('${student.fullName}  •  ${student.studentNumber}'),
          pw.Text('${student.department}  •  Year ${student.year}'),
          pw.Text(
            'GPA ${student.gpa.toStringAsFixed(2)}  •  Attendance ${student.attendanceRate.toStringAsFixed(0)}%',
          ),
          pw.SizedBox(height: 18),
          pw.Table.fromTextArray(
            headers: const [
              'Course',
              'Semester',
              'Grade',
              'Score',
              'Attendance',
            ],
            data: [
              for (final course in student.courses)
                [
                  '${course.code} ${course.title}',
                  course.semester,
                  course.grade,
                  course.score.toStringAsFixed(0),
                  '${course.attendanceRate.toStringAsFixed(0)}%',
                ],
            ],
          ),
          pw.SizedBox(height: 18),
          pw.Text(
            'Emergency contact: ${student.emergencyContact.name} (${student.emergencyContact.relationship}) - ${student.emergencyContact.phone}',
          ),
        ],
      ),
    );
    return Uint8List.fromList(await pdf.save());
  }

  Future<Uint8List> buildAnalyticsReportPdf() async {
    final pdf = pw.Document();
    final distribution = _snapshot.departmentDistribution.entries.toList()
      ..sort((left, right) => right.value.compareTo(left.value));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) => [
          pw.Text(
            'Student Management Analytics',
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 16),
          pw.Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _metricCard('Total students', _snapshot.totalStudents.toString()),
              _metricCard(
                'Active courses',
                _snapshot.activeCoursesCount.toString(),
              ),
              _metricCard(
                'Pending approvals',
                _snapshot.pendingApprovals.toString(),
              ),
              _metricCard(
                'Average GPA',
                _snapshot.averageGpa.toStringAsFixed(2),
              ),
            ],
          ),
          pw.SizedBox(height: 18),
          pw.Text(
            'Department distribution',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Table.fromTextArray(
            headers: const ['Department', 'Students'],
            data: [
              for (final item in distribution)
                [item.key, item.value.toString()],
            ],
          ),
          pw.SizedBox(height: 18),
          pw.Text(
            'Enrollment trend',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Table.fromTextArray(
            headers: const ['Period', 'Enrollments'],
            data: [
              for (final point in _snapshot.enrollmentTrend)
                [point.label, point.value.toStringAsFixed(0)],
            ],
          ),
        ],
      ),
    );
    return Uint8List.fromList(await pdf.save());
  }

  Future<Uint8List> buildDocumentBundle(String studentId) async {
    final student = _snapshot.findStudent(studentId);
    if (student == null) return Uint8List(0);

    final archive = Archive();
    for (final document in student.documents) {
      final bytes =
          document.localBytes ??
          Uint8List.fromList(
            utf8.encode(
              [
                'Document: ${document.name}',
                'Category: ${document.category}',
                'Status: ${document.status.label}',
                'Uploaded: ${document.uploadedAt.toIso8601String()}',
                if (document.notes != null) 'Notes: ${document.notes}',
              ].join('\n'),
            ),
          );
      archive.addFile(ArchiveFile(document.name, bytes.length, bytes));
    }

    try {
      await _apiService.requestDocumentBundle(
        studentId: studentId,
        documentIds: student.documents.map((item) => item.id).toList(),
      );
    } catch (_) {}

    return Uint8List.fromList(ZipEncoder().encode(archive) ?? <int>[]);
  }

  StudentModuleSnapshot appendAlert(StudentModuleAlert alert) {
    _snapshot = _snapshot.copyWith(
      alerts: [alert, ..._snapshot.alerts.take(7)],
      generatedAt: DateTime.now(),
    );
    return _snapshot;
  }
}

pw.Widget _metricCard(String title, String value) {
  return pw.Container(
    width: 120,
    padding: const pw.EdgeInsets.all(12),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.blueGrey300),
      borderRadius: pw.BorderRadius.circular(10),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: const pw.TextStyle(fontSize: 10)),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
      ],
    ),
  );
}

StudentModuleSnapshot _buildSeedSnapshot() {
  final now = DateTime.now();
  final students = [
    _studentSeed(
      id: 'stu_2401',
      studentNumber: 'ST-2401',
      fullName: 'Omar Adel',
      year: 4,
      department: 'Computer Science',
      className: 'CS-4A',
      email: 'omar.adel@tolab.edu',
      phone: '+20 101 778 2201',
      address: 'Nasr City, Cairo',
      emergencyName: 'Adel Hassan',
      emergencyRelationship: 'Father',
      emergencyPhone: '+20 122 996 3105',
      enrollmentStatus: StudentEnrollmentStatus.active,
      gpa: 3.82,
      attendanceRate: 94,
      averageGrade: 91,
      registrationApproved: true,
      coursePrefix: 'CS',
      courseTitleA: 'Advanced Algorithms',
      courseTitleB: 'Distributed Systems',
      courseTitleC: 'Data Mining',
      groupIds: const ['grp_cs_4a'],
      notes:
          'Final-year student with strong performance and consistent submissions.',
      lastLoginAt: now.subtract(const Duration(minutes: 18)),
      scoreOffset: 4,
    ),
    _studentSeed(
      id: 'stu_2408',
      studentNumber: 'ST-2408',
      fullName: 'Mariam Tarek',
      year: 3,
      department: 'Information Systems',
      className: 'IS-3B',
      email: 'mariam.tarek@tolab.edu',
      phone: '+20 114 921 5433',
      address: 'Heliopolis, Cairo',
      emergencyName: 'Tarek Fawzy',
      emergencyRelationship: 'Brother',
      emergencyPhone: '+20 102 551 2266',
      enrollmentStatus: StudentEnrollmentStatus.pendingApproval,
      gpa: 3.89,
      attendanceRate: 96,
      averageGrade: 94,
      registrationApproved: false,
      coursePrefix: 'IS',
      courseTitleA: 'Enterprise Systems',
      courseTitleB: 'Business Intelligence',
      courseTitleC: 'Systems Analysis',
      groupIds: const ['grp_is_3b'],
      notes: 'Awaiting final enrollment approval after capacity review.',
      lastLoginAt: now.subtract(const Duration(minutes: 5)),
      scoreOffset: 7,
    ),
    _studentSeed(
      id: 'stu_2414',
      studentNumber: 'ST-2414',
      fullName: 'Youssef Ali',
      year: 2,
      department: 'Engineering',
      className: 'ENG-2A',
      email: 'youssef.ali@tolab.edu',
      phone: '+20 100 664 1182',
      address: 'Madinaty, Cairo',
      emergencyName: 'Nourhan Ali',
      emergencyRelationship: 'Mother',
      emergencyPhone: '+20 120 004 2281',
      enrollmentStatus: StudentEnrollmentStatus.probation,
      gpa: 2.48,
      attendanceRate: 72,
      averageGrade: 68,
      registrationApproved: false,
      coursePrefix: 'ENG',
      courseTitleA: 'Thermodynamics',
      courseTitleB: 'Mechanics II',
      courseTitleC: 'Applied Mathematics',
      groupIds: const ['grp_eng_2a'],
      notes: 'Flagged for academic recovery workflow and attendance coaching.',
      lastLoginAt: now.subtract(const Duration(hours: 4)),
      scoreOffset: -8,
    ),
    _studentSeed(
      id: 'stu_2420',
      studentNumber: 'ST-2420',
      fullName: 'Salma Nabil',
      year: 3,
      department: 'Computer Science',
      className: 'CS-3C',
      email: 'salma.nabil@tolab.edu',
      phone: '+20 102 331 7784',
      address: 'New Cairo',
      emergencyName: 'Nabil Fares',
      emergencyRelationship: 'Father',
      emergencyPhone: '+20 100 771 1903',
      enrollmentStatus: StudentEnrollmentStatus.active,
      gpa: 3.48,
      attendanceRate: 88,
      averageGrade: 86,
      registrationApproved: true,
      coursePrefix: 'CS',
      courseTitleA: 'Mobile Development',
      courseTitleB: 'Compiler Design',
      courseTitleC: 'Theory of Computation',
      groupIds: const ['grp_cs_3c'],
      notes: 'Good scholarship profile with stable attendance.',
      lastLoginAt: now.subtract(const Duration(minutes: 44)),
      scoreOffset: 1,
    ),
    _studentSeed(
      id: 'stu_2429',
      studentNumber: 'ST-2429',
      fullName: 'Karim Essam',
      year: 2,
      department: 'Computer Science',
      className: 'CS-2D',
      email: 'karim.essam@tolab.edu',
      phone: '+20 111 210 4406',
      address: 'Shorouk',
      emergencyName: 'Essam Mahmoud',
      emergencyRelationship: 'Father',
      emergencyPhone: '+20 114 200 1189',
      enrollmentStatus: StudentEnrollmentStatus.pendingApproval,
      gpa: 2.27,
      attendanceRate: 76,
      averageGrade: 64,
      registrationApproved: false,
      coursePrefix: 'CS',
      courseTitleA: 'Discrete Structures',
      courseTitleB: 'Computer Organization',
      courseTitleC: 'Intro to Databases',
      groupIds: const ['grp_cs_2d'],
      notes: 'Pending probation clearance and advisor signoff.',
      lastLoginAt: now.subtract(const Duration(days: 1)),
      scoreOffset: -10,
    ),
    _studentSeed(
      id: 'stu_2435',
      studentNumber: 'ST-2435',
      fullName: 'Farah Mohamed',
      year: 4,
      department: 'Information Systems',
      className: 'IS-4A',
      email: 'farah.mohamed@tolab.edu',
      phone: '+20 112 775 3401',
      address: 'Dokki, Giza',
      emergencyName: 'Mohamed Ashraf',
      emergencyRelationship: 'Father',
      emergencyPhone: '+20 100 900 4427',
      enrollmentStatus: StudentEnrollmentStatus.active,
      gpa: 3.36,
      attendanceRate: 87,
      averageGrade: 84,
      registrationApproved: true,
      coursePrefix: 'IS',
      courseTitleA: 'ERP Systems',
      courseTitleB: 'IT Governance',
      courseTitleC: 'Project Management',
      groupIds: const ['grp_is_4a'],
      notes: 'Graduation audit is healthy and documents are fully approved.',
      lastLoginAt: now.subtract(const Duration(hours: 1)),
      scoreOffset: -1,
    ),
  ];

  final groups = [
    StudentGroupRecord(
      id: 'grp_cs_4a',
      name: 'CS Leadership Sprint',
      department: 'Computer Science',
      year: 4,
      className: 'CS-4A',
      memberIds: const ['stu_2401'],
      leaderId: 'stu_2401',
      representativeId: 'stu_2401',
      courseTitle: 'Advanced Algorithms',
      lastAnnouncementAt: now.subtract(const Duration(hours: 2)),
    ),
    StudentGroupRecord(
      id: 'grp_is_3b',
      name: 'IS Insight Crew',
      department: 'Information Systems',
      year: 3,
      className: 'IS-3B',
      memberIds: const ['stu_2408'],
      leaderId: 'stu_2408',
      representativeId: 'stu_2408',
      courseTitle: 'Business Intelligence',
      lastAnnouncementAt: now.subtract(const Duration(hours: 6)),
    ),
    StudentGroupRecord(
      id: 'grp_eng_2a',
      name: 'Engineering Recovery Circle',
      department: 'Engineering',
      year: 2,
      className: 'ENG-2A',
      memberIds: const ['stu_2414'],
      leaderId: 'stu_2414',
      representativeId: 'stu_2414',
      courseTitle: 'Thermodynamics',
      lastAnnouncementAt: now.subtract(const Duration(days: 1)),
    ),
    StudentGroupRecord(
      id: 'grp_cs_3c',
      name: 'CS Product Lab',
      department: 'Computer Science',
      year: 3,
      className: 'CS-3C',
      memberIds: const ['stu_2420'],
      leaderId: 'stu_2420',
      representativeId: 'stu_2420',
      courseTitle: 'Mobile Development',
      lastAnnouncementAt: now.subtract(const Duration(hours: 4)),
    ),
    StudentGroupRecord(
      id: 'grp_cs_2d',
      name: 'CS Foundations Support',
      department: 'Computer Science',
      year: 2,
      className: 'CS-2D',
      memberIds: const ['stu_2429'],
      leaderId: 'stu_2429',
      representativeId: 'stu_2429',
      courseTitle: 'Discrete Structures',
      lastAnnouncementAt: now.subtract(const Duration(days: 2)),
    ),
    StudentGroupRecord(
      id: 'grp_is_4a',
      name: 'IS Capstone Launchpad',
      department: 'Information Systems',
      year: 4,
      className: 'IS-4A',
      memberIds: const ['stu_2435'],
      leaderId: 'stu_2435',
      representativeId: 'stu_2435',
      courseTitle: 'ERP Systems',
      lastAnnouncementAt: now.subtract(const Duration(hours: 3)),
    ),
  ];

  final campaigns = [
    StudentMessageCampaign(
      id: 'cmp-01',
      title: 'Registration packet reminder',
      body:
          'Pending approvals must be finalized before Wednesday 5 PM to keep scheduling access.',
      audienceLabel: 'Pending approvals',
      channel: StudentCommunicationChannel.push,
      sentAt: now.subtract(const Duration(hours: 3)),
      recipients: 2,
      delivered: 2,
      opened: 1,
      recipientStudentIds: const ['stu_2408', 'stu_2429'],
    ),
    StudentMessageCampaign(
      id: 'cmp-02',
      title: 'Attendance recovery workshop',
      body:
          'Engineering and probation cohorts have a mandatory recovery session tomorrow morning.',
      audienceLabel: 'At-risk cohort',
      channel: StudentCommunicationChannel.email,
      sentAt: now.subtract(const Duration(days: 1)),
      recipients: 2,
      delivered: 2,
      opened: 2,
      recipientStudentIds: const ['stu_2414', 'stu_2429'],
      groupId: 'grp_eng_2a',
    ),
  ];

  final alerts = [
    _alert(
      title: '2 approvals pending',
      body: 'Mariam Tarek and Karim Essam still require admin approval.',
      severity: StudentAlertSeverity.warning,
      badgeLabel: 'Approvals',
      createdAt: now.subtract(const Duration(minutes: 9)),
    ),
    _alert(
      title: 'Document issue detected',
      body: 'Youssef Ali has a rejected financial clearance document.',
      severity: StudentAlertSeverity.critical,
      badgeLabel: 'Documents',
      createdAt: now.subtract(const Duration(hours: 1)),
    ),
    _alert(
      title: 'Attendance streak improved',
      body: 'Salma Nabil closed her previous attendance watch flag.',
      severity: StudentAlertSeverity.success,
      badgeLabel: 'Attendance',
      createdAt: now.subtract(const Duration(hours: 5)),
    ),
  ];

  final trend = const [
    StudentEnrollmentPoint(label: 'Oct', value: 146),
    StudentEnrollmentPoint(label: 'Nov', value: 151),
    StudentEnrollmentPoint(label: 'Dec', value: 158),
    StudentEnrollmentPoint(label: 'Jan', value: 164),
    StudentEnrollmentPoint(label: 'Feb', value: 172),
    StudentEnrollmentPoint(label: 'Mar', value: 181),
  ];

  return StudentModuleSnapshot(
    students: students,
    groups: groups,
    campaigns: campaigns,
    alerts: alerts,
    enrollmentTrend: trend,
    generatedAt: now,
  );
}

StudentProfile _studentSeed({
  required String id,
  required String studentNumber,
  required String fullName,
  required int year,
  required String department,
  required String className,
  required String email,
  required String phone,
  required String address,
  required String emergencyName,
  required String emergencyRelationship,
  required String emergencyPhone,
  required StudentEnrollmentStatus enrollmentStatus,
  required double gpa,
  required double attendanceRate,
  required double averageGrade,
  required bool registrationApproved,
  required String coursePrefix,
  required String courseTitleA,
  required String courseTitleB,
  required String courseTitleC,
  required List<String> groupIds,
  required String notes,
  required DateTime lastLoginAt,
  required int scoreOffset,
}) {
  final now = DateTime.now();
  final activities = [
    _activity(
      id: '$id-login',
      studentId: id,
      type: StudentActivityType.login,
      title: 'Latest login',
      description:
          'Student accessed the academy portal from the web dashboard.',
      occurredAt: lastLoginAt,
    ),
    _activity(
      id: '$id-assignment',
      studentId: id,
      type: StudentActivityType.assignment,
      title: 'Assignment submitted',
      description: '$courseTitleA milestone submitted for review.',
      occurredAt: now.subtract(const Duration(days: 1, hours: 2)),
      courseTitle: courseTitleA,
    ),
    _activity(
      id: '$id-forum',
      studentId: id,
      type: StudentActivityType.forumPost,
      title: 'Forum contribution',
      description: 'Shared a peer response inside the course discussion space.',
      occurredAt: now.subtract(const Duration(days: 2, hours: 4)),
      courseTitle: courseTitleB,
    ),
    _activity(
      id: '$id-message',
      studentId: id,
      type: StudentActivityType.message,
      title: 'Advisor message',
      description: 'Admin or advisor sent a follow-up workflow message.',
      occurredAt: now.subtract(const Duration(days: 3)),
    ),
  ];

  final documents = [
    _document(
      '$id-doc-id',
      'National ID.pdf',
      'Identity',
      StudentDocumentStatus.approved,
      now.subtract(const Duration(days: 20)),
      '254 KB',
    ),
    _document(
      '$id-doc-cert',
      'Secondary Certificate.pdf',
      'Certificate',
      enrollmentStatus == StudentEnrollmentStatus.pendingApproval
          ? StudentDocumentStatus.pending
          : StudentDocumentStatus.approved,
      now.subtract(const Duration(days: 11)),
      '410 KB',
    ),
    _document(
      '$id-doc-assign',
      'Portfolio.zip',
      'Assignment',
      enrollmentStatus == StudentEnrollmentStatus.probation
          ? StudentDocumentStatus.rejected
          : StudentDocumentStatus.pending,
      now.subtract(const Duration(days: 3)),
      '1.3 MB',
    ),
  ];

  return StudentProfile(
    id: id,
    studentNumber: studentNumber,
    fullName: fullName,
    year: year,
    department: department,
    className: className,
    contact: StudentContactInfo(email: email, phone: phone, address: address),
    emergencyContact: StudentEmergencyContact(
      name: emergencyName,
      relationship: emergencyRelationship,
      phone: emergencyPhone,
    ),
    enrollmentStatus: enrollmentStatus,
    gpa: gpa,
    attendanceRate: attendanceRate,
    averageGrade: averageGrade,
    registrationApproved: registrationApproved,
    courses: [
      _course(
        '$id-c1',
        '$coursePrefix${100 + year * 10 + 1}',
        courseTitleA,
        score: 87 + scoreOffset,
        semester: 'Spring 2026',
        attendanceRate: attendanceRate,
      ),
      _course(
        '$id-c2',
        '$coursePrefix${100 + year * 10 + 2}',
        courseTitleB,
        score: 82 + scoreOffset,
        semester: 'Spring 2026',
        attendanceRate: attendanceRate - 4,
      ),
      _course(
        '$id-c3',
        '$coursePrefix${100 + year * 10 + 3}',
        courseTitleC,
        score: 79 + scoreOffset,
        semester: 'Fall 2025',
        attendanceRate: attendanceRate - 2,
        isCurrentTerm: false,
      ),
    ],
    documents: documents,
    activities: activities,
    memberships: [
      for (final groupId in groupIds)
        StudentGroupMembership(
          groupId: groupId,
          roleLabel: enrollmentStatus == StudentEnrollmentStatus.active
              ? 'Leader'
              : 'Representative',
        ),
    ],
    createdAt: now.subtract(const Duration(days: 120)),
    lastLoginAt: lastLoginAt,
    notes: notes,
  );
}

StudentCourseGrade _course(
  String id,
  String code,
  String title, {
  required int score,
  required String semester,
  required double attendanceRate,
  bool isCurrentTerm = true,
}) {
  return StudentCourseGrade(
    id: id,
    code: code,
    title: title,
    instructor: 'Dr. ${title.split(' ').first} Coordinator',
    semester: semester,
    credits: 3,
    score: score.toDouble(),
    grade: _gradeForScore(score.toDouble()),
    attendanceRate: attendanceRate,
    status: isCurrentTerm ? 'Ongoing' : 'Completed',
    isCurrentTerm: isCurrentTerm,
  );
}

StudentDocumentRecord _document(
  String id,
  String name,
  String category,
  StudentDocumentStatus status,
  DateTime uploadedAt,
  String sizeLabel,
) {
  return StudentDocumentRecord(
    id: id,
    name: name,
    category: category,
    status: status,
    uploadedAt: uploadedAt,
    sizeLabel: sizeLabel,
    notes: status == StudentDocumentStatus.rejected
        ? 'Resubmission required due to unreadable attachment.'
        : null,
    localBytes: Uint8List.fromList(
      utf8.encode('$name\nCategory: $category\nStatus: ${status.label}\n'),
    ),
  );
}

StudentActivityRecord _activity({
  required String id,
  required String studentId,
  required StudentActivityType type,
  required String title,
  required String description,
  required DateTime occurredAt,
  String? courseTitle,
}) {
  return StudentActivityRecord(
    id: id,
    studentId: studentId,
    type: type,
    title: title,
    description: description,
    occurredAt: occurredAt,
    courseTitle: courseTitle,
  );
}

StudentModuleAlert _alert({
  required String title,
  required String body,
  required StudentAlertSeverity severity,
  required String badgeLabel,
  DateTime? createdAt,
}) {
  return StudentModuleAlert(
    id: 'alert-${DateTime.now().microsecondsSinceEpoch}-${title.hashCode}',
    title: title,
    body: body,
    severity: severity,
    createdAt: createdAt ?? DateTime.now(),
    badgeLabel: badgeLabel,
  );
}

String _gradeForScore(double score) {
  if (score >= 90) return 'A';
  if (score >= 85) return 'B+';
  if (score >= 80) return 'B';
  if (score >= 75) return 'C+';
  if (score >= 70) return 'C';
  if (score >= 65) return 'D';
  return 'F';
}

String _courseCode(String courseTitle) {
  final tokens = courseTitle
      .split(' ')
      .where((token) => token.trim().isNotEmpty)
      .map((token) => token.characters.first.toUpperCase())
      .take(3)
      .join();
  return '${tokens.padRight(3, 'X')}${100 + Random().nextInt(300)}';
}

String _formatFileSize(int bytes) {
  if (bytes >= 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  if (bytes >= 1024) {
    return '${(bytes / 1024).toStringAsFixed(0)} KB';
  }
  return '$bytes B';
}

List<StudentProfile> _sortStudents(List<StudentProfile> students) {
  final items = [...students]
    ..sort((left, right) => left.fullName.compareTo(right.fullName));
  return List<StudentProfile>.unmodifiable(items);
}

Map<StudentImportField, String?> _autoMapColumns(List<String> headers) {
  String? match(List<String> aliases) {
    for (final header in headers) {
      final normalized = _normalizeHeader(header);
      if (aliases.any((alias) => normalized == _normalizeHeader(alias))) {
        return header;
      }
    }
    return null;
  }

  return {
    StudentImportField.fullName: match(['name', 'full name', 'student name']),
    StudentImportField.studentId: match(['id', 'student id', 'student_number']),
    StudentImportField.email: match(['email', 'mail']),
    StudentImportField.department: match(['department', 'major']),
    StudentImportField.year: match(['year', 'level']),
    StudentImportField.phone: match(['phone', 'mobile']),
    StudentImportField.emergencyName: match([
      'emergency contact',
      'emergency name',
    ]),
    StudentImportField.emergencyPhone: match([
      'emergency phone',
      'guardian phone',
    ]),
    StudentImportField.status: match(['status', 'enrollment status']),
    StudentImportField.gpa: match(['gpa']),
    StudentImportField.attendance: match(['attendance', 'attendance %']),
    StudentImportField.course: match(['course', 'primary course']),
  };
}

String _normalizeHeader(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
}

List<List<String>> _readSpreadsheetRows(String fileName, Uint8List bytes) {
  final lowerName = fileName.toLowerCase();
  if (lowerName.endsWith('.csv')) {
    return _parseCsv(utf8.decode(bytes));
  }

  final decoder = SpreadsheetDecoder.decodeBytes(bytes, update: true);
  if (decoder.tables.isEmpty) return const [];
  final table = decoder.tables.values.first;
  return [
    for (final row in table.rows)
      [for (final cell in row) cell?.toString() ?? ''],
  ];
}

List<List<String>> _parseCsv(String content) {
  final rows = <List<String>>[];
  final row = <String>[];
  final buffer = StringBuffer();
  var insideQuotes = false;

  for (var index = 0; index < content.length; index++) {
    final char = content[index];
    if (char == '"') {
      final nextIsQuote =
          index + 1 < content.length && content[index + 1] == '"';
      if (insideQuotes && nextIsQuote) {
        buffer.write('"');
        index++;
      } else {
        insideQuotes = !insideQuotes;
      }
      continue;
    }
    if (char == ',' && !insideQuotes) {
      row.add(buffer.toString());
      buffer.clear();
      continue;
    }
    if ((char == '\n' || char == '\r') && !insideQuotes) {
      if (char == '\r' &&
          index + 1 < content.length &&
          content[index + 1] == '\n') {
        index++;
      }
      row.add(buffer.toString());
      buffer.clear();
      if (row.any((item) => item.trim().isNotEmpty)) {
        rows.add(List<String>.from(row));
      }
      row.clear();
      continue;
    }
    buffer.write(char);
  }

  if (buffer.isNotEmpty || row.isNotEmpty) {
    row.add(buffer.toString());
    rows.add(List<String>.from(row));
  }
  return rows;
}

List<StudentProfile> _rowsFromPreview(StudentImportPreview preview) {
  final mapping = preview.columnMapping;
  final now = DateTime.now();
  return [
    for (final row in preview.rows)
      StudentProfile(
        id: '',
        studentNumber: row[mapping[StudentImportField.studentId] ?? ''] ?? '',
        fullName: row[mapping[StudentImportField.fullName] ?? ''] ?? '',
        year:
            int.tryParse(row[mapping[StudentImportField.year] ?? ''] ?? '') ??
            1,
        department:
            row[mapping[StudentImportField.department] ?? ''] ??
            'General Studies',
        className:
            '${(row[mapping[StudentImportField.department] ?? ''] ?? 'GEN').split(' ').first.toUpperCase()}-${row[mapping[StudentImportField.year] ?? ''] ?? '1'}A',
        contact: StudentContactInfo(
          email: row[mapping[StudentImportField.email] ?? ''] ?? '',
          phone: row[mapping[StudentImportField.phone] ?? ''] ?? '',
          address: 'Imported from ${preview.fileName}',
        ),
        emergencyContact: StudentEmergencyContact(
          name: row[mapping[StudentImportField.emergencyName] ?? ''] ?? 'TBD',
          relationship: 'Guardian',
          phone: row[mapping[StudentImportField.emergencyPhone] ?? ''] ?? '',
        ),
        enrollmentStatus: StudentEnrollmentStatusX.fromValue(
          row[mapping[StudentImportField.status] ?? ''],
        ),
        gpa:
            double.tryParse(row[mapping[StudentImportField.gpa] ?? ''] ?? '') ??
            0,
        attendanceRate:
            double.tryParse(
              row[mapping[StudentImportField.attendance] ?? ''] ?? '',
            ) ??
            0,
        averageGrade: max(
          60,
          (double.tryParse(row[mapping[StudentImportField.gpa] ?? ''] ?? '') ??
                  2.5) *
              22,
        ),
        registrationApproved: false,
        courses: [
          StudentCourseGrade(
            id: 'import-${row.hashCode}',
            code: _courseCode(
              row[mapping[StudentImportField.course] ?? ''] ?? 'Orientation',
            ),
            title:
                row[mapping[StudentImportField.course] ?? ''] ?? 'Orientation',
            instructor: 'Pending assignment',
            semester: 'Spring 2026',
            credits: 3,
            score: 0,
            grade: 'Pending',
            attendanceRate: 0,
            status: 'Pending',
          ),
        ],
        documents: [
          _document(
            'import-doc-${row.hashCode}',
            'Imported Registration Sheet.txt',
            'Import',
            StudentDocumentStatus.pending,
            now,
            '1 KB',
          ),
        ],
        activities: [
          _activity(
            id: 'import-activity-${row.hashCode}',
            studentId: row[mapping[StudentImportField.studentId] ?? ''] ?? '',
            type: StudentActivityType.approval,
            title: 'Imported from bulk upload',
            description: 'Student record created through CSV/Excel intake.',
            occurredAt: now,
          ),
        ],
        memberships: const [],
        createdAt: now,
        lastLoginAt: now,
        notes: 'Imported through admin bulk upload pipeline.',
      ),
  ];
}
