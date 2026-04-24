enum CommunityPostType { announcement, question, discussion }

class CommunityComment {
  const CommunityComment({
    required this.id,
    required this.authorName,
    required this.content,
    required this.createdAtLabel,
  });

  final String id;
  final String authorName;
  final String content;
  final String createdAtLabel;
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
  });

  final String id;
  final String subjectId;
  final String authorName;
  final String content;
  final String sentAtLabel;
  final bool isMine;
}
