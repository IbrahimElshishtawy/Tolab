enum SupportTicketStatus { pending, inProgress, resolved }

enum SupportTicketPriority { low, medium, high, urgent }

enum SupportTicketCategory { technical, subject, quiz, result, other }

extension SupportTicketStatusX on SupportTicketStatus {
  String get label => switch (this) {
    SupportTicketStatus.pending => 'قيد الانتظار',
    SupportTicketStatus.inProgress => 'قيد المعالجة',
    SupportTicketStatus.resolved => 'تم الحل',
  };
}

extension SupportTicketPriorityX on SupportTicketPriority {
  String get label => switch (this) {
    SupportTicketPriority.low => 'منخفضة',
    SupportTicketPriority.medium => 'متوسطة',
    SupportTicketPriority.high => 'مرتفعة',
    SupportTicketPriority.urgent => 'عاجلة',
  };
}

extension SupportTicketCategoryX on SupportTicketCategory {
  String get label => switch (this) {
    SupportTicketCategory.technical => 'مشكلة تقنية',
    SupportTicketCategory.subject => 'مشكلة في مادة',
    SupportTicketCategory.quiz => 'مشكلة في كويز',
    SupportTicketCategory.result => 'مشكلة في نتيجة',
    SupportTicketCategory.other => 'أخرى',
  };
}

class SupportMessage {
  const SupportMessage({
    required this.id,
    required this.authorName,
    required this.content,
    required this.createdAtLabel,
    required this.isMine,
    this.attachmentName,
  });

  final String id;
  final String authorName;
  final String content;
  final String createdAtLabel;
  final bool isMine;
  final String? attachmentName;
}

class SupportTicket {
  const SupportTicket({
    required this.id,
    required this.ticketId,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    required this.createdAtLabel,
    required this.updatedAtLabel,
    required this.studentName,
    required this.studentCode,
    this.subjectId,
    this.subjectName,
    this.attachmentName,
    this.messages = const [],
  });

  final String id;
  final String ticketId;
  final String title;
  final String description;
  final SupportTicketCategory category;
  final SupportTicketPriority priority;
  final SupportTicketStatus status;
  final String createdAtLabel;
  final String updatedAtLabel;
  final String studentName;
  final String studentCode;
  final String? subjectId;
  final String? subjectName;
  final String? attachmentName;
  final List<SupportMessage> messages;

  SupportTicket copyWith({
    String? id,
    String? ticketId,
    String? title,
    String? description,
    SupportTicketCategory? category,
    SupportTicketPriority? priority,
    SupportTicketStatus? status,
    String? createdAtLabel,
    String? updatedAtLabel,
    String? studentName,
    String? studentCode,
    String? subjectId,
    String? subjectName,
    String? attachmentName,
    List<SupportMessage>? messages,
  }) {
    return SupportTicket(
      id: id ?? this.id,
      ticketId: ticketId ?? this.ticketId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAtLabel: createdAtLabel ?? this.createdAtLabel,
      updatedAtLabel: updatedAtLabel ?? this.updatedAtLabel,
      studentName: studentName ?? this.studentName,
      studentCode: studentCode ?? this.studentCode,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      attachmentName: attachmentName ?? this.attachmentName,
      messages: messages ?? this.messages,
    );
  }
}

class SupportTicketDraft {
  const SupportTicketDraft({
    required this.category,
    required this.priority,
    required this.title,
    required this.description,
    this.subjectId,
    this.subjectName,
    this.attachmentName,
  });

  final SupportTicketCategory category;
  final SupportTicketPriority priority;
  final String title;
  final String description;
  final String? subjectId;
  final String? subjectName;
  final String? attachmentName;
}
