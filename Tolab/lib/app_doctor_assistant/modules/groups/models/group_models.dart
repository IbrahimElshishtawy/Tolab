class SubjectGroupModel {
  const SubjectGroupModel({
    required this.subjectId,
    required this.subjectName,
    required this.subjectCode,
    required this.groupName,
    required this.summary,
    required this.posts,
    required this.latestComments,
    required this.activity,
    this.postsCount = 0,
    this.commentsCount = 0,
    this.engagementCount = 0,
  });

  final int subjectId;
  final String subjectName;
  final String subjectCode;
  final String groupName;
  final String summary;
  final List<GroupPostModel> posts;
  final List<GroupCommentModel> latestComments;
  final List<GroupActivityItem> activity;
  final int postsCount;
  final int commentsCount;
  final int engagementCount;

  factory SubjectGroupModel.fromJson(Map<String, dynamic> json) {
    return SubjectGroupModel(
      subjectId: (json['subject_id'] as num?)?.toInt() ?? 0,
      subjectName: json['subject_name']?.toString() ?? '',
      subjectCode: json['subject_code']?.toString() ?? '',
      groupName: json['group_name']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      postsCount: (json['posts_count'] as num?)?.toInt() ?? 0,
      commentsCount: (json['comments_count'] as num?)?.toInt() ?? 0,
      engagementCount: (json['engagement_count'] as num?)?.toInt() ?? 0,
      posts: (json['posts'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(GroupPostModel.fromJson)
          .toList(growable: false),
      latestComments: (json['latest_comments'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(GroupCommentModel.fromJson)
          .toList(growable: false),
      activity: (json['activity'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(GroupActivityItem.fromJson)
          .toList(growable: false),
    );
  }
}

class GroupPostModel {
  const GroupPostModel({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.content,
    required this.authorName,
    required this.authorRole,
    required this.createdAt,
    required this.updatedAt,
    this.type = 'post',
    this.priority = 'normal',
    this.isPinned = false,
    this.comments = const <GroupCommentModel>[],
    this.commentsCount = 0,
    this.reactionsCount = 0,
    this.attachmentLabel,
    this.attachmentUrl,
  });

  final int id;
  final int subjectId;
  final String title;
  final String content;
  final String authorName;
  final String authorRole;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String type;
  final String priority;
  final bool isPinned;
  final List<GroupCommentModel> comments;
  final int commentsCount;
  final int reactionsCount;
  final String? attachmentLabel;
  final String? attachmentUrl;

  factory GroupPostModel.fromJson(Map<String, dynamic> json) {
    return GroupPostModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      subjectId: (json['subject_id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? json['content_text']?.toString() ?? '',
      authorName: json['author_name']?.toString() ?? '',
      authorRole: json['author_role']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime(2026, 4, 22),
      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime(2026, 4, 22),
      type: json['type']?.toString() ?? json['post_type']?.toString() ?? 'post',
      priority: json['priority']?.toString() ?? 'normal',
      isPinned: json['is_pinned'] == true,
      commentsCount: (json['comments_count'] as num?)?.toInt() ?? 0,
      reactionsCount: (json['reactions_count'] as num?)?.toInt() ?? 0,
      attachmentLabel: json['attachment_label']?.toString(),
      attachmentUrl: json['attachment_url']?.toString(),
      comments: (json['comments'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(GroupCommentModel.fromJson)
          .toList(growable: false),
    );
  }
}

class GroupCommentModel {
  const GroupCommentModel({
    required this.id,
    required this.postId,
    required this.authorName,
    required this.authorRole,
    required this.message,
    required this.createdAt,
  });

  final int id;
  final int postId;
  final String authorName;
  final String authorRole;
  final String message;
  final DateTime createdAt;

  factory GroupCommentModel.fromJson(Map<String, dynamic> json) {
    return GroupCommentModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      postId: (json['post_id'] as num?)?.toInt() ?? 0,
      authorName: json['author_name']?.toString() ?? '',
      authorRole: json['author_role']?.toString() ?? '',
      message: json['message']?.toString() ?? json['text']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime(2026, 4, 22),
    );
  }
}

class GroupActivityItem {
  const GroupActivityItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.createdAt,
  });

  final int id;
  final String title;
  final String subtitle;
  final String type;
  final DateTime createdAt;

  factory GroupActivityItem.fromJson(Map<String, dynamic> json) {
    return GroupActivityItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      type: json['type']?.toString() ?? 'activity',
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime(2026, 4, 22),
    );
  }
}
