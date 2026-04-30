enum CommunityPostType { announcement, question, discussion }

class CourseGroup {
  const CourseGroup({
    required this.id,
    required this.courseOfferingId,
    required this.courseName,
    required this.doctorName,
    required this.assistantName,
    required this.membersCount,
    required this.onlineCount,
    this.pinnedAnnouncement,
  });

  final String id;
  final String courseOfferingId;
  final String courseName;
  final String doctorName;
  final String assistantName;
  final int membersCount;
  final int onlineCount;
  final String? pinnedAnnouncement;
}

class CommunityComment {
  const CommunityComment({
    required this.id,
    required this.authorName,
    required this.content,
    required this.createdAtLabel,
    this.authorRole,
    this.isImportant = false,
  });

  final String id;
  final String authorName;
  final String content;
  final String createdAtLabel;
  final String? authorRole;
  final bool isImportant;
}

class CommunityPost {
  const CommunityPost({
    required this.id,
    required this.subjectId,
    required this.authorName,
    required this.authorRole,
    required this.content,
    required this.createdAtLabel,
    required this.reactions,
    required this.comments,
    this.type = CommunityPostType.discussion,
    this.isPinned = false,
    this.title,
    this.subjectName,
    this.preview,
    this.isImportant = false,
    this.isUrgent = false,
    this.attachments = const [],
    this.attachmentName,
  });

  final String id;
  final String subjectId;
  final String authorName;
  final String authorRole;
  final String content;
  final String createdAtLabel;
  final int reactions;
  final List<CommunityComment> comments;
  final CommunityPostType type;
  final bool isPinned;
  final String? title;
  final String? subjectName;
  final String? preview;
  final bool isImportant;
  final bool isUrgent;
  final List<String> attachments;
  final String? attachmentName;

  CommunityPost copyWith({
    String? id,
    String? subjectId,
    String? authorName,
    String? authorRole,
    String? content,
    String? createdAtLabel,
    int? reactions,
    List<CommunityComment>? comments,
    CommunityPostType? type,
    bool? isPinned,
    String? title,
    String? subjectName,
    String? preview,
    bool? isImportant,
    bool? isUrgent,
    List<String>? attachments,
    String? attachmentName,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      authorName: authorName ?? this.authorName,
      authorRole: authorRole ?? this.authorRole,
      content: content ?? this.content,
      createdAtLabel: createdAtLabel ?? this.createdAtLabel,
      reactions: reactions ?? this.reactions,
      comments: comments ?? this.comments,
      type: type ?? this.type,
      isPinned: isPinned ?? this.isPinned,
      title: title ?? this.title,
      subjectName: subjectName ?? this.subjectName,
      preview: preview ?? this.preview,
      isImportant: isImportant ?? this.isImportant,
      isUrgent: isUrgent ?? this.isUrgent,
      attachments: attachments ?? this.attachments,
      attachmentName: attachmentName ?? this.attachmentName,
    );
  }
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.subjectId,
    required this.authorName,
    required this.content,
    required this.sentAtLabel,
    required this.isMine,
    this.authorRole = 'student',
  });

  final String id;
  final String subjectId;
  final String authorName;
  final String content;
  final String sentAtLabel;
  final bool isMine;
  final String authorRole;
}
