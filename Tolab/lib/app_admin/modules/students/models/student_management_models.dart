import 'dart:typed_data';

import '../../../core/helpers/json_types.dart';

enum StudentWorkspaceTab { overview, registry, activity, groups, communication }

extension StudentWorkspaceTabX on StudentWorkspaceTab {
  String get label => switch (this) {
    StudentWorkspaceTab.overview => 'Overview',
    StudentWorkspaceTab.registry => 'Registry',
    StudentWorkspaceTab.activity => 'Activity',
    StudentWorkspaceTab.groups => 'Groups',
    StudentWorkspaceTab.communication => 'Communication',
  };
}

enum StudentEnrollmentStatus {
  active,
  pendingApproval,
  probation,
  suspended,
  alumni,
}

extension StudentEnrollmentStatusX on StudentEnrollmentStatus {
  String get label => switch (this) {
    StudentEnrollmentStatus.active => 'Active',
    StudentEnrollmentStatus.pendingApproval => 'Pending approval',
    StudentEnrollmentStatus.probation => 'Probation',
    StudentEnrollmentStatus.suspended => 'Suspended',
    StudentEnrollmentStatus.alumni => 'Alumni',
  };

  String get backendValue => switch (this) {
    StudentEnrollmentStatus.active => 'active',
    StudentEnrollmentStatus.pendingApproval => 'pending_approval',
    StudentEnrollmentStatus.probation => 'probation',
    StudentEnrollmentStatus.suspended => 'suspended',
    StudentEnrollmentStatus.alumni => 'alumni',
  };

  static StudentEnrollmentStatus fromValue(String? value) {
    final normalized = value?.trim().toLowerCase().replaceAll(' ', '_') ?? '';
    return switch (normalized) {
      'active' => StudentEnrollmentStatus.active,
      'pending' ||
      'pending_approval' ||
      'pendingapproval' => StudentEnrollmentStatus.pendingApproval,
      'probation' => StudentEnrollmentStatus.probation,
      'suspended' => StudentEnrollmentStatus.suspended,
      'alumni' => StudentEnrollmentStatus.alumni,
      _ => StudentEnrollmentStatus.active,
    };
  }
}

enum StudentDocumentStatus { pending, approved, rejected }

extension StudentDocumentStatusX on StudentDocumentStatus {
  String get label => switch (this) {
    StudentDocumentStatus.pending => 'Pending',
    StudentDocumentStatus.approved => 'Approved',
    StudentDocumentStatus.rejected => 'Rejected',
  };

  String get backendValue => switch (this) {
    StudentDocumentStatus.pending => 'pending',
    StudentDocumentStatus.approved => 'approved',
    StudentDocumentStatus.rejected => 'rejected',
  };

  static StudentDocumentStatus fromValue(String? value) {
    final normalized = value?.trim().toLowerCase() ?? '';
    return switch (normalized) {
      'approved' => StudentDocumentStatus.approved,
      'rejected' => StudentDocumentStatus.rejected,
      _ => StudentDocumentStatus.pending,
    };
  }
}

enum StudentActivityType {
  login,
  assignment,
  forumPost,
  message,
  submission,
  document,
  approval,
}

extension StudentActivityTypeX on StudentActivityType {
  String get label => switch (this) {
    StudentActivityType.login => 'Login',
    StudentActivityType.assignment => 'Assignment',
    StudentActivityType.forumPost => 'Forum post',
    StudentActivityType.message => 'Message',
    StudentActivityType.submission => 'Submission',
    StudentActivityType.document => 'Document',
    StudentActivityType.approval => 'Approval',
  };

  String get backendValue => switch (this) {
    StudentActivityType.login => 'login',
    StudentActivityType.assignment => 'assignment',
    StudentActivityType.forumPost => 'forum_post',
    StudentActivityType.message => 'message',
    StudentActivityType.submission => 'submission',
    StudentActivityType.document => 'document',
    StudentActivityType.approval => 'approval',
  };

  static StudentActivityType fromValue(String? value) {
    final normalized = value?.trim().toLowerCase().replaceAll(' ', '_') ?? '';
    return switch (normalized) {
      'login' => StudentActivityType.login,
      'assignment' => StudentActivityType.assignment,
      'forum_post' || 'forumpost' => StudentActivityType.forumPost,
      'message' => StudentActivityType.message,
      'submission' => StudentActivityType.submission,
      'document' => StudentActivityType.document,
      'approval' => StudentActivityType.approval,
      _ => StudentActivityType.login,
    };
  }
}

enum StudentCommunicationChannel { inApp, email, push }

extension StudentCommunicationChannelX on StudentCommunicationChannel {
  String get label => switch (this) {
    StudentCommunicationChannel.inApp => 'In-app',
    StudentCommunicationChannel.email => 'Email',
    StudentCommunicationChannel.push => 'Push',
  };

  String get backendValue => switch (this) {
    StudentCommunicationChannel.inApp => 'in_app',
    StudentCommunicationChannel.email => 'email',
    StudentCommunicationChannel.push => 'push',
  };

  static StudentCommunicationChannel fromValue(String? value) {
    final normalized = value?.trim().toLowerCase().replaceAll('-', '_') ?? '';
    return switch (normalized) {
      'email' => StudentCommunicationChannel.email,
      'push' => StudentCommunicationChannel.push,
      _ => StudentCommunicationChannel.inApp,
    };
  }
}

enum StudentAlertSeverity { info, success, warning, critical }

extension StudentAlertSeverityX on StudentAlertSeverity {
  String get label => switch (this) {
    StudentAlertSeverity.info => 'Info',
    StudentAlertSeverity.success => 'Resolved',
    StudentAlertSeverity.warning => 'Attention',
    StudentAlertSeverity.critical => 'Critical',
  };
}

enum StudentBulkActionType {
  approveRegistrations,
  rejectRegistrations,
  assignCourse,
  updateStatus,
}

extension StudentBulkActionTypeX on StudentBulkActionType {
  String get label => switch (this) {
    StudentBulkActionType.approveRegistrations => 'Approve registrations',
    StudentBulkActionType.rejectRegistrations => 'Reject registrations',
    StudentBulkActionType.assignCourse => 'Assign course',
    StudentBulkActionType.updateStatus => 'Update status',
  };

  String get backendValue => switch (this) {
    StudentBulkActionType.approveRegistrations => 'approve_registrations',
    StudentBulkActionType.rejectRegistrations => 'reject_registrations',
    StudentBulkActionType.assignCourse => 'assign_course',
    StudentBulkActionType.updateStatus => 'update_status',
  };
}

enum StudentImportField {
  fullName,
  studentId,
  email,
  department,
  year,
  phone,
  emergencyName,
  emergencyPhone,
  status,
  gpa,
  attendance,
  course,
}

extension StudentImportFieldX on StudentImportField {
  String get label => switch (this) {
    StudentImportField.fullName => 'Full name',
    StudentImportField.studentId => 'Student ID',
    StudentImportField.email => 'Email',
    StudentImportField.department => 'Department',
    StudentImportField.year => 'Year',
    StudentImportField.phone => 'Phone',
    StudentImportField.emergencyName => 'Emergency contact',
    StudentImportField.emergencyPhone => 'Emergency phone',
    StudentImportField.status => 'Enrollment status',
    StudentImportField.gpa => 'GPA',
    StudentImportField.attendance => 'Attendance',
    StudentImportField.course => 'Primary course',
  };
}

enum StudentAnalyticsWindow { month, quarter, year }

extension StudentAnalyticsWindowX on StudentAnalyticsWindow {
  String get label => switch (this) {
    StudentAnalyticsWindow.month => '30 days',
    StudentAnalyticsWindow.quarter => 'Quarter',
    StudentAnalyticsWindow.year => 'Year',
  };
}

class StudentUploadedFile {
  const StudentUploadedFile({
    required this.name,
    required this.bytes,
    required this.sizeInBytes,
    this.mimeType,
  });

  final String name;
  final Uint8List bytes;
  final int sizeInBytes;
  final String? mimeType;
}

class StudentContactInfo {
  const StudentContactInfo({
    required this.email,
    required this.phone,
    required this.address,
  });

  final String email;
  final String phone;
  final String address;

  StudentContactInfo copyWith({String? email, String? phone, String? address}) {
    return StudentContactInfo(
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }

  factory StudentContactInfo.fromJson(JsonMap json) {
    return StudentContactInfo(
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
    );
  }

  JsonMap toJson() => {'email': email, 'phone': phone, 'address': address};
}

class StudentEmergencyContact {
  const StudentEmergencyContact({
    required this.name,
    required this.relationship,
    required this.phone,
  });

  final String name;
  final String relationship;
  final String phone;

  StudentEmergencyContact copyWith({
    String? name,
    String? relationship,
    String? phone,
  }) {
    return StudentEmergencyContact(
      name: name ?? this.name,
      relationship: relationship ?? this.relationship,
      phone: phone ?? this.phone,
    );
  }

  factory StudentEmergencyContact.fromJson(JsonMap json) {
    return StudentEmergencyContact(
      name: json['name']?.toString() ?? '',
      relationship: json['relationship']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
    );
  }

  JsonMap toJson() => {
    'name': name,
    'relationship': relationship,
    'phone': phone,
  };
}

class StudentCourseGrade {
  const StudentCourseGrade({
    required this.id,
    required this.code,
    required this.title,
    required this.instructor,
    required this.semester,
    required this.credits,
    required this.score,
    required this.grade,
    required this.attendanceRate,
    required this.status,
    this.isCurrentTerm = true,
  });

  final String id;
  final String code;
  final String title;
  final String instructor;
  final String semester;
  final int credits;
  final double score;
  final String grade;
  final double attendanceRate;
  final String status;
  final bool isCurrentTerm;

  StudentCourseGrade copyWith({
    String? id,
    String? code,
    String? title,
    String? instructor,
    String? semester,
    int? credits,
    double? score,
    String? grade,
    double? attendanceRate,
    String? status,
    bool? isCurrentTerm,
  }) {
    return StudentCourseGrade(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      instructor: instructor ?? this.instructor,
      semester: semester ?? this.semester,
      credits: credits ?? this.credits,
      score: score ?? this.score,
      grade: grade ?? this.grade,
      attendanceRate: attendanceRate ?? this.attendanceRate,
      status: status ?? this.status,
      isCurrentTerm: isCurrentTerm ?? this.isCurrentTerm,
    );
  }

  factory StudentCourseGrade.fromJson(JsonMap json) {
    return StudentCourseGrade(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      instructor: json['instructor']?.toString() ?? '',
      semester: json['semester']?.toString() ?? '',
      credits: _asInt(json['credits']),
      score: _asDouble(json['score']),
      grade: json['grade']?.toString() ?? '',
      attendanceRate: _asDouble(
        json['attendance_rate'] ?? json['attendanceRate'],
      ),
      status: json['status']?.toString() ?? '',
      isCurrentTerm: _asBool(json['is_current_term'] ?? json['isCurrentTerm']),
    );
  }

  JsonMap toJson() => {
    'id': id,
    'code': code,
    'title': title,
    'instructor': instructor,
    'semester': semester,
    'credits': credits,
    'score': score,
    'grade': grade,
    'attendance_rate': attendanceRate,
    'status': status,
    'is_current_term': isCurrentTerm,
  };
}

class StudentDocumentRecord {
  const StudentDocumentRecord({
    required this.id,
    required this.name,
    required this.category,
    required this.status,
    required this.uploadedAt,
    required this.sizeLabel,
    this.notes,
    this.downloadUrl,
    this.localBytes,
    this.mimeType,
  });

  final String id;
  final String name;
  final String category;
  final StudentDocumentStatus status;
  final DateTime uploadedAt;
  final String sizeLabel;
  final String? notes;
  final String? downloadUrl;
  final Uint8List? localBytes;
  final String? mimeType;

  StudentDocumentRecord copyWith({
    String? id,
    String? name,
    String? category,
    StudentDocumentStatus? status,
    DateTime? uploadedAt,
    String? sizeLabel,
    String? notes,
    String? downloadUrl,
    Uint8List? localBytes,
    String? mimeType,
    bool clearNotes = false,
    bool clearDownloadUrl = false,
    bool clearLocalBytes = false,
    bool clearMimeType = false,
  }) {
    return StudentDocumentRecord(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      status: status ?? this.status,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      sizeLabel: sizeLabel ?? this.sizeLabel,
      notes: clearNotes ? null : notes ?? this.notes,
      downloadUrl: clearDownloadUrl ? null : downloadUrl ?? this.downloadUrl,
      localBytes: clearLocalBytes ? null : localBytes ?? this.localBytes,
      mimeType: clearMimeType ? null : mimeType ?? this.mimeType,
    );
  }

  factory StudentDocumentRecord.fromJson(JsonMap json) {
    return StudentDocumentRecord(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      status: StudentDocumentStatusX.fromValue(json['status']?.toString()),
      uploadedAt: _parseDateTime(json['uploaded_at'] ?? json['uploadedAt']),
      sizeLabel:
          json['size_label']?.toString() ?? json['size']?.toString() ?? '',
      notes: json['notes']?.toString(),
      downloadUrl: json['download_url']?.toString(),
      mimeType: json['mime_type']?.toString(),
    );
  }

  JsonMap toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'status': status.backendValue,
    'uploaded_at': uploadedAt.toIso8601String(),
    'size_label': sizeLabel,
    'notes': notes,
    'download_url': downloadUrl,
    'mime_type': mimeType,
  };
}

class StudentActivityRecord {
  const StudentActivityRecord({
    required this.id,
    required this.studentId,
    required this.type,
    required this.title,
    required this.description,
    required this.occurredAt,
    this.courseTitle,
  });

  final String id;
  final String studentId;
  final StudentActivityType type;
  final String title;
  final String description;
  final DateTime occurredAt;
  final String? courseTitle;

  factory StudentActivityRecord.fromJson(JsonMap json) {
    return StudentActivityRecord(
      id: json['id']?.toString() ?? '',
      studentId: json['student_id']?.toString() ?? '',
      type: StudentActivityTypeX.fromValue(json['type']?.toString()),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      occurredAt: _parseDateTime(json['occurred_at'] ?? json['occurredAt']),
      courseTitle: json['course_title']?.toString(),
    );
  }

  JsonMap toJson() => {
    'id': id,
    'student_id': studentId,
    'type': type.backendValue,
    'title': title,
    'description': description,
    'occurred_at': occurredAt.toIso8601String(),
    'course_title': courseTitle,
  };
}

class StudentGroupMembership {
  const StudentGroupMembership({
    required this.groupId,
    required this.roleLabel,
  });

  final String groupId;
  final String roleLabel;

  factory StudentGroupMembership.fromJson(JsonMap json) {
    return StudentGroupMembership(
      groupId: json['group_id']?.toString() ?? '',
      roleLabel: json['role_label']?.toString() ?? '',
    );
  }

  JsonMap toJson() => {'group_id': groupId, 'role_label': roleLabel};
}

class StudentProfile {
  const StudentProfile({
    required this.id,
    required this.studentNumber,
    required this.fullName,
    required this.year,
    required this.department,
    required this.className,
    required this.contact,
    required this.emergencyContact,
    required this.enrollmentStatus,
    required this.gpa,
    required this.attendanceRate,
    required this.averageGrade,
    required this.registrationApproved,
    required this.courses,
    required this.documents,
    required this.activities,
    required this.memberships,
    required this.createdAt,
    required this.lastLoginAt,
    this.photoUrl,
    this.notes = '',
  });

  final String id;
  final String studentNumber;
  final String fullName;
  final int year;
  final String department;
  final String className;
  final StudentContactInfo contact;
  final StudentEmergencyContact emergencyContact;
  final StudentEnrollmentStatus enrollmentStatus;
  final double gpa;
  final double attendanceRate;
  final double averageGrade;
  final bool registrationApproved;
  final List<StudentCourseGrade> courses;
  final List<StudentDocumentRecord> documents;
  final List<StudentActivityRecord> activities;
  final List<StudentGroupMembership> memberships;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final String? photoUrl;
  final String notes;

  bool get isAtRisk =>
      gpa < 2.5 ||
      attendanceRate < 78 ||
      enrollmentStatus == StudentEnrollmentStatus.probation ||
      enrollmentStatus == StudentEnrollmentStatus.suspended;

  int get pendingDocumentCount => documents
      .where((item) => item.status == StudentDocumentStatus.pending)
      .length;

  int get completedCredits => courses
      .where((item) => !item.isCurrentTerm)
      .fold(0, (sum, item) => sum + item.credits);

  int get activeCredits => courses
      .where((item) => item.isCurrentTerm)
      .fold(0, (sum, item) => sum + item.credits);

  StudentProfile copyWith({
    String? id,
    String? studentNumber,
    String? fullName,
    int? year,
    String? department,
    String? className,
    StudentContactInfo? contact,
    StudentEmergencyContact? emergencyContact,
    StudentEnrollmentStatus? enrollmentStatus,
    double? gpa,
    double? attendanceRate,
    double? averageGrade,
    bool? registrationApproved,
    List<StudentCourseGrade>? courses,
    List<StudentDocumentRecord>? documents,
    List<StudentActivityRecord>? activities,
    List<StudentGroupMembership>? memberships,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? photoUrl,
    String? notes,
    bool clearPhotoUrl = false,
  }) {
    return StudentProfile(
      id: id ?? this.id,
      studentNumber: studentNumber ?? this.studentNumber,
      fullName: fullName ?? this.fullName,
      year: year ?? this.year,
      department: department ?? this.department,
      className: className ?? this.className,
      contact: contact ?? this.contact,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      enrollmentStatus: enrollmentStatus ?? this.enrollmentStatus,
      gpa: gpa ?? this.gpa,
      attendanceRate: attendanceRate ?? this.attendanceRate,
      averageGrade: averageGrade ?? this.averageGrade,
      registrationApproved: registrationApproved ?? this.registrationApproved,
      courses: courses ?? this.courses,
      documents: documents ?? this.documents,
      activities: activities ?? this.activities,
      memberships: memberships ?? this.memberships,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      photoUrl: clearPhotoUrl ? null : photoUrl ?? this.photoUrl,
      notes: notes ?? this.notes,
    );
  }

  factory StudentProfile.fromJson(JsonMap json) {
    return StudentProfile(
      id: json['id']?.toString() ?? '',
      studentNumber:
          json['student_number']?.toString() ??
          json['studentNumber']?.toString() ??
          '',
      fullName:
          json['full_name']?.toString() ?? json['fullName']?.toString() ?? '',
      year: _asInt(json['year']),
      department: json['department']?.toString() ?? '',
      className:
          json['class_name']?.toString() ?? json['className']?.toString() ?? '',
      contact: StudentContactInfo.fromJson(_asMap(json['contact'])),
      emergencyContact: StudentEmergencyContact.fromJson(
        _asMap(json['emergency_contact'] ?? json['emergencyContact']),
      ),
      enrollmentStatus: StudentEnrollmentStatusX.fromValue(
        json['enrollment_status']?.toString() ??
            json['enrollmentStatus']?.toString(),
      ),
      gpa: _asDouble(json['gpa']),
      attendanceRate: _asDouble(
        json['attendance_rate'] ?? json['attendanceRate'],
      ),
      averageGrade: _asDouble(json['average_grade'] ?? json['averageGrade']),
      registrationApproved: _asBool(
        json['registration_approved'] ?? json['registrationApproved'],
      ),
      courses: _asList(json['courses'])
          .map((item) => StudentCourseGrade.fromJson(_asMap(item)))
          .toList(growable: false),
      documents: _asList(json['documents'])
          .map((item) => StudentDocumentRecord.fromJson(_asMap(item)))
          .toList(growable: false),
      activities: _asList(json['activities'])
          .map((item) => StudentActivityRecord.fromJson(_asMap(item)))
          .toList(growable: false),
      memberships: _asList(json['memberships'])
          .map((item) => StudentGroupMembership.fromJson(_asMap(item)))
          .toList(growable: false),
      createdAt: _parseDateTime(json['created_at'] ?? json['createdAt']),
      lastLoginAt: _parseDateTime(json['last_login_at'] ?? json['lastLoginAt']),
      photoUrl: json['photo_url']?.toString() ?? json['photoUrl']?.toString(),
      notes: json['notes']?.toString() ?? '',
    );
  }

  JsonMap toJson() => {
    'id': id,
    'student_number': studentNumber,
    'full_name': fullName,
    'year': year,
    'department': department,
    'class_name': className,
    'contact': contact.toJson(),
    'emergency_contact': emergencyContact.toJson(),
    'enrollment_status': enrollmentStatus.backendValue,
    'gpa': gpa,
    'attendance_rate': attendanceRate,
    'average_grade': averageGrade,
    'registration_approved': registrationApproved,
    'courses': courses.map((item) => item.toJson()).toList(growable: false),
    'documents': documents.map((item) => item.toJson()).toList(growable: false),
    'activities': activities
        .map((item) => item.toJson())
        .toList(growable: false),
    'memberships': memberships
        .map((item) => item.toJson())
        .toList(growable: false),
    'created_at': createdAt.toIso8601String(),
    'last_login_at': lastLoginAt.toIso8601String(),
    'photo_url': photoUrl,
    'notes': notes,
  };
}

class StudentGroupRecord {
  const StudentGroupRecord({
    required this.id,
    required this.name,
    required this.department,
    required this.year,
    required this.className,
    required this.memberIds,
    required this.leaderId,
    required this.representativeId,
    required this.courseTitle,
    required this.lastAnnouncementAt,
  });

  final String id;
  final String name;
  final String department;
  final int year;
  final String className;
  final List<String> memberIds;
  final String leaderId;
  final String representativeId;
  final String courseTitle;
  final DateTime lastAnnouncementAt;

  StudentGroupRecord copyWith({
    String? id,
    String? name,
    String? department,
    int? year,
    String? className,
    List<String>? memberIds,
    String? leaderId,
    String? representativeId,
    String? courseTitle,
    DateTime? lastAnnouncementAt,
  }) {
    return StudentGroupRecord(
      id: id ?? this.id,
      name: name ?? this.name,
      department: department ?? this.department,
      year: year ?? this.year,
      className: className ?? this.className,
      memberIds: memberIds ?? this.memberIds,
      leaderId: leaderId ?? this.leaderId,
      representativeId: representativeId ?? this.representativeId,
      courseTitle: courseTitle ?? this.courseTitle,
      lastAnnouncementAt: lastAnnouncementAt ?? this.lastAnnouncementAt,
    );
  }

  factory StudentGroupRecord.fromJson(JsonMap json) {
    return StudentGroupRecord(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      year: _asInt(json['year']),
      className: json['class_name']?.toString() ?? '',
      memberIds: _asList(
        json['member_ids'],
      ).map((item) => item.toString()).toList(growable: false),
      leaderId: json['leader_id']?.toString() ?? '',
      representativeId: json['representative_id']?.toString() ?? '',
      courseTitle: json['course_title']?.toString() ?? '',
      lastAnnouncementAt: _parseDateTime(
        json['last_announcement_at'] ?? json['lastAnnouncementAt'],
      ),
    );
  }

  JsonMap toJson() => {
    'id': id,
    'name': name,
    'department': department,
    'year': year,
    'class_name': className,
    'member_ids': memberIds,
    'leader_id': leaderId,
    'representative_id': representativeId,
    'course_title': courseTitle,
    'last_announcement_at': lastAnnouncementAt.toIso8601String(),
  };
}

class StudentMessageCampaign {
  const StudentMessageCampaign({
    required this.id,
    required this.title,
    required this.body,
    required this.audienceLabel,
    required this.channel,
    required this.sentAt,
    required this.recipients,
    required this.delivered,
    required this.opened,
    required this.recipientStudentIds,
    this.groupId,
  });

  final String id;
  final String title;
  final String body;
  final String audienceLabel;
  final StudentCommunicationChannel channel;
  final DateTime sentAt;
  final int recipients;
  final int delivered;
  final int opened;
  final List<String> recipientStudentIds;
  final String? groupId;

  factory StudentMessageCampaign.fromJson(JsonMap json) {
    return StudentMessageCampaign(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      audienceLabel: json['audience_label']?.toString() ?? '',
      channel: StudentCommunicationChannelX.fromValue(
        json['channel']?.toString(),
      ),
      sentAt: _parseDateTime(json['sent_at'] ?? json['sentAt']),
      recipients: _asInt(json['recipients']),
      delivered: _asInt(json['delivered']),
      opened: _asInt(json['opened']),
      recipientStudentIds: _asList(
        json['recipient_student_ids'],
      ).map((item) => item.toString()).toList(growable: false),
      groupId: json['group_id']?.toString(),
    );
  }

  JsonMap toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'audience_label': audienceLabel,
    'channel': channel.backendValue,
    'sent_at': sentAt.toIso8601String(),
    'recipients': recipients,
    'delivered': delivered,
    'opened': opened,
    'recipient_student_ids': recipientStudentIds,
    'group_id': groupId,
  };
}

class StudentModuleAlert {
  const StudentModuleAlert({
    required this.id,
    required this.title,
    required this.body,
    required this.severity,
    required this.createdAt,
    required this.badgeLabel,
  });

  final String id;
  final String title;
  final String body;
  final StudentAlertSeverity severity;
  final DateTime createdAt;
  final String badgeLabel;

  factory StudentModuleAlert.fromJson(JsonMap json) {
    return StudentModuleAlert(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      severity: switch (json['severity']?.toString().trim().toLowerCase()) {
        'success' => StudentAlertSeverity.success,
        'warning' => StudentAlertSeverity.warning,
        'critical' => StudentAlertSeverity.critical,
        _ => StudentAlertSeverity.info,
      },
      createdAt: _parseDateTime(json['created_at'] ?? json['createdAt']),
      badgeLabel: json['badge_label']?.toString() ?? '',
    );
  }

  JsonMap toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'severity': severity.label.toLowerCase(),
    'created_at': createdAt.toIso8601String(),
    'badge_label': badgeLabel,
  };
}

class StudentEnrollmentPoint {
  const StudentEnrollmentPoint({required this.label, required this.value});

  final String label;
  final double value;

  factory StudentEnrollmentPoint.fromJson(JsonMap json) {
    return StudentEnrollmentPoint(
      label: json['label']?.toString() ?? '',
      value: _asDouble(json['value']),
    );
  }

  JsonMap toJson() => {'label': label, 'value': value};
}

class StudentImportPreview {
  const StudentImportPreview({
    required this.fileName,
    required this.headers,
    required this.rows,
    required this.columnMapping,
    required this.duplicates,
    required this.invalidRows,
    required this.validRows,
  });

  final String fileName;
  final List<String> headers;
  final List<Map<String, String>> rows;
  final Map<StudentImportField, String?> columnMapping;
  final List<String> duplicates;
  final int invalidRows;
  final int validRows;

  int get totalRows => rows.length;

  StudentImportPreview copyWith({
    String? fileName,
    List<String>? headers,
    List<Map<String, String>>? rows,
    Map<StudentImportField, String?>? columnMapping,
    List<String>? duplicates,
    int? invalidRows,
    int? validRows,
  }) {
    return StudentImportPreview(
      fileName: fileName ?? this.fileName,
      headers: headers ?? this.headers,
      rows: rows ?? this.rows,
      columnMapping: columnMapping ?? this.columnMapping,
      duplicates: duplicates ?? this.duplicates,
      invalidRows: invalidRows ?? this.invalidRows,
      validRows: validRows ?? this.validRows,
    );
  }
}

class StudentImportResult {
  const StudentImportResult({
    required this.imported,
    required this.duplicates,
    required this.failed,
    required this.summary,
  });

  final int imported;
  final int duplicates;
  final int failed;
  final String summary;
}

class StudentFilters {
  const StudentFilters({
    this.query = '',
    this.department = 'All departments',
    this.year = 'All years',
    this.enrollmentStatus = 'All statuses',
    this.gpaBand = 'All GPA',
    this.attendanceBand = 'All attendance',
    this.course = 'All courses',
    this.activityType = 'All activity',
    this.analyticsWindow = StudentAnalyticsWindow.quarter,
  });

  final String query;
  final String department;
  final String year;
  final String enrollmentStatus;
  final String gpaBand;
  final String attendanceBand;
  final String course;
  final String activityType;
  final StudentAnalyticsWindow analyticsWindow;

  StudentFilters copyWith({
    String? query,
    String? department,
    String? year,
    String? enrollmentStatus,
    String? gpaBand,
    String? attendanceBand,
    String? course,
    String? activityType,
    StudentAnalyticsWindow? analyticsWindow,
    bool clearQuery = false,
  }) {
    return StudentFilters(
      query: clearQuery ? '' : query ?? this.query,
      department: department ?? this.department,
      year: year ?? this.year,
      enrollmentStatus: enrollmentStatus ?? this.enrollmentStatus,
      gpaBand: gpaBand ?? this.gpaBand,
      attendanceBand: attendanceBand ?? this.attendanceBand,
      course: course ?? this.course,
      activityType: activityType ?? this.activityType,
      analyticsWindow: analyticsWindow ?? this.analyticsWindow,
    );
  }
}

class StudentModuleSnapshot {
  const StudentModuleSnapshot({
    required this.students,
    required this.groups,
    required this.campaigns,
    required this.alerts,
    required this.enrollmentTrend,
    required this.generatedAt,
  });

  final List<StudentProfile> students;
  final List<StudentGroupRecord> groups;
  final List<StudentMessageCampaign> campaigns;
  final List<StudentModuleAlert> alerts;
  final List<StudentEnrollmentPoint> enrollmentTrend;
  final DateTime generatedAt;

  int get totalStudents => students.length;

  int get pendingApprovals => students
      .where(
        (item) =>
            item.enrollmentStatus == StudentEnrollmentStatus.pendingApproval,
      )
      .length;

  int get pendingDocuments =>
      students.fold(0, (sum, item) => sum + item.pendingDocumentCount);

  int get activeCoursesCount => {
    for (final student in students)
      for (final course in student.courses.where((item) => item.isCurrentTerm))
        course.code,
  }.length;

  double get averageGpa => students.isEmpty
      ? 0
      : students.fold<double>(0, (sum, item) => sum + item.gpa) /
            students.length;

  double get averageAttendance => students.isEmpty
      ? 0
      : students.fold<double>(0, (sum, item) => sum + item.attendanceRate) /
            students.length;

  double get averageGrade => students.isEmpty
      ? 0
      : students.fold<double>(0, (sum, item) => sum + item.averageGrade) /
            students.length;

  List<StudentActivityRecord> get allActivities {
    final items = <StudentActivityRecord>[
      for (final student in students) ...student.activities,
    ]..sort((left, right) => right.occurredAt.compareTo(left.occurredAt));
    return List<StudentActivityRecord>.unmodifiable(items);
  }

  Map<String, int> get departmentDistribution {
    final counts = <String, int>{};
    for (final student in students) {
      counts.update(
        student.department,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }
    return counts;
  }

  StudentProfile? findStudent(String? id) {
    if (id == null) return null;
    for (final student in students) {
      if (student.id == id) return student;
    }
    return null;
  }

  StudentModuleSnapshot copyWith({
    List<StudentProfile>? students,
    List<StudentGroupRecord>? groups,
    List<StudentMessageCampaign>? campaigns,
    List<StudentModuleAlert>? alerts,
    List<StudentEnrollmentPoint>? enrollmentTrend,
    DateTime? generatedAt,
  }) {
    return StudentModuleSnapshot(
      students: students ?? this.students,
      groups: groups ?? this.groups,
      campaigns: campaigns ?? this.campaigns,
      alerts: alerts ?? this.alerts,
      enrollmentTrend: enrollmentTrend ?? this.enrollmentTrend,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  factory StudentModuleSnapshot.fromJson(JsonMap json) {
    return StudentModuleSnapshot(
      students: _asList(json['students'])
          .map((item) => StudentProfile.fromJson(_asMap(item)))
          .toList(growable: false),
      groups: _asList(json['groups'])
          .map((item) => StudentGroupRecord.fromJson(_asMap(item)))
          .toList(growable: false),
      campaigns: _asList(json['campaigns'])
          .map((item) => StudentMessageCampaign.fromJson(_asMap(item)))
          .toList(growable: false),
      alerts: _asList(json['alerts'])
          .map((item) => StudentModuleAlert.fromJson(_asMap(item)))
          .toList(growable: false),
      enrollmentTrend:
          _asList(json['enrollment_trend'] ?? json['enrollmentTrend'])
              .map((item) => StudentEnrollmentPoint.fromJson(_asMap(item)))
              .toList(growable: false),
      generatedAt: _parseDateTime(json['generated_at'] ?? json['generatedAt']),
    );
  }

  JsonMap toJson() => {
    'students': students.map((item) => item.toJson()).toList(growable: false),
    'groups': groups.map((item) => item.toJson()).toList(growable: false),
    'campaigns': campaigns.map((item) => item.toJson()).toList(growable: false),
    'alerts': alerts.map((item) => item.toJson()).toList(growable: false),
    'enrollment_trend': enrollmentTrend
        .map((item) => item.toJson())
        .toList(growable: false),
    'generated_at': generatedAt.toIso8601String(),
  };
}

JsonMap _asMap(dynamic value) {
  if (value is JsonMap) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

List<dynamic> _asList(dynamic value) {
  if (value is List) return value;
  return const <dynamic>[];
}

DateTime _parseDateTime(dynamic value) {
  if (value is DateTime) return value.toLocal();
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value).toLocal();
  if (value is String && value.trim().isNotEmpty) {
    return DateTime.tryParse(value)?.toLocal() ?? DateTime.now();
  }
  return DateTime.now();
}

double _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim()) ?? 0;
  return 0;
}

int _asInt(dynamic value) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim()) ?? 0;
  return 0;
}

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }
  return false;
}
