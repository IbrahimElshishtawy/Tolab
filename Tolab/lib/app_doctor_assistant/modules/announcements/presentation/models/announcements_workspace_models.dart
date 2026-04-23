import 'package:flutter/material.dart';

import '../../../../core/models/session_user.dart';
import '../../../../mock/doctor_assistant_mock_repository.dart';
import '../../../../mock/mock_portal_models.dart';
import '../../../groups/models/group_models.dart';

enum AnnouncementFeedFilter { all, mySubjects, urgent, pinned, recent }

extension AnnouncementFeedFilterX on AnnouncementFeedFilter {
  String get label => switch (this) {
    AnnouncementFeedFilter.all => 'All',
    AnnouncementFeedFilter.mySubjects => 'My subjects',
    AnnouncementFeedFilter.urgent => 'Urgent',
    AnnouncementFeedFilter.pinned => 'Pinned',
    AnnouncementFeedFilter.recent => 'Recent',
  };
}

class AnnouncementSubjectOption {
  const AnnouncementSubjectOption({
    required this.id,
    required this.code,
    required this.name,
  });

  final int id;
  final String code;
  final String name;
}

class AnnouncementComposerDraft {
  const AnnouncementComposerDraft({
    required this.id,
    required this.subjectId,
    required this.subjectCode,
    required this.subjectName,
    required this.title,
    required this.content,
    required this.type,
    required this.isPinned,
    required this.isUrgent,
    this.attachmentLabel,
  });

  final int id;
  final int subjectId;
  final String subjectCode;
  final String subjectName;
  final String title;
  final String content;
  final String type;
  final bool isPinned;
  final bool isUrgent;
  final String? attachmentLabel;

  AnnouncementFeedItem toFeedItem() {
    return AnnouncementFeedItem(
      id: id,
      subjectId: subjectId,
      subjectCode: subjectCode,
      subjectName: subjectName,
      title: title,
      content: content,
      authorName: 'Draft workspace',
      authorRole: 'staff',
      type: type,
      priority: isUrgent ? 'urgent' : 'normal',
      isPinned: isPinned,
      createdAt: DateTime(2026, 4, 23, 12, 0),
      updatedAt: DateTime(2026, 4, 23, 12, 0),
      commentsCount: 0,
      reactionsCount: 0,
      attachmentLabel: attachmentLabel,
      comments: const <AnnouncementCommentItem>[],
      statusLabel: 'Draft',
      isDraft: true,
    );
  }
}

class AnnouncementCommentItem {
  const AnnouncementCommentItem({
    required this.id,
    required this.authorName,
    required this.authorRole,
    required this.message,
    required this.createdAt,
    this.replies = const <AnnouncementCommentReplyItem>[],
  });

  final int id;
  final String authorName;
  final String authorRole;
  final String message;
  final DateTime createdAt;
  final List<AnnouncementCommentReplyItem> replies;
}

class AnnouncementCommentReplyItem {
  const AnnouncementCommentReplyItem({
    required this.id,
    required this.authorName,
    required this.message,
    required this.createdAt,
  });

  final int id;
  final String authorName;
  final String message;
  final DateTime createdAt;
}

class AnnouncementFeedItem {
  const AnnouncementFeedItem({
    required this.id,
    required this.subjectId,
    required this.subjectCode,
    required this.subjectName,
    required this.title,
    required this.content,
    required this.authorName,
    required this.authorRole,
    required this.type,
    required this.priority,
    required this.isPinned,
    required this.createdAt,
    required this.updatedAt,
    required this.commentsCount,
    required this.reactionsCount,
    required this.comments,
    required this.statusLabel,
    this.attachmentLabel,
    this.isDraft = false,
  });

  final int id;
  final int subjectId;
  final String subjectCode;
  final String subjectName;
  final String title;
  final String content;
  final String authorName;
  final String authorRole;
  final String type;
  final String priority;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int commentsCount;
  final int reactionsCount;
  final String? attachmentLabel;
  final List<AnnouncementCommentItem> comments;
  final String statusLabel;
  final bool isDraft;

  bool get isUrgent => priority.toLowerCase() == 'urgent';
}

class AnnouncementActivityItem {
  const AnnouncementActivityItem({
    required this.title,
    required this.subtitle,
    required this.timestampLabel,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final String timestampLabel;
  final IconData icon;
  final Color color;
}

class AnnouncementsWorkspaceData {
  const AnnouncementsWorkspaceData({
    required this.subjects,
    required this.feed,
    required this.activity,
    required this.unresolvedThreads,
    required this.studentQuestions,
  });

  final List<AnnouncementSubjectOption> subjects;
  final List<AnnouncementFeedItem> feed;
  final List<AnnouncementActivityItem> activity;
  final List<AnnouncementActivityItem> unresolvedThreads;
  final List<AnnouncementActivityItem> studentQuestions;
}

AnnouncementsWorkspaceData buildAnnouncementsWorkspace(
  DoctorAssistantMockRepository repository,
  SessionUser user, {
  List<AnnouncementComposerDraft> drafts = const <AnnouncementComposerDraft>[],
  Map<int, List<AnnouncementCommentItem>> localComments = const <int, List<AnnouncementCommentItem>>{},
}) {
  final subjects = repository.subjectsFor(user)
      .map(
        (subject) => AnnouncementSubjectOption(
          id: subject.id,
          code: subject.code,
          name: subject.name,
        ),
      )
      .toList(growable: false);

  final announcementFeed = repository.announcementsFor(user)
      .map(
        (item) => AnnouncementFeedItem(
          id: item.id.hashCode.abs(),
          subjectId: subjects
                  .where((subject) => subject.code == item.subjectCode)
                  .firstOrNull
                  ?.id ??
              0,
          subjectCode: item.subjectCode,
          subjectName: subjects
                  .where((subject) => subject.code == item.subjectCode)
                  .firstOrNull
                  ?.name ??
              item.subjectCode,
          title: item.title,
          content: item.body,
          authorName: item.authorName,
          authorRole: 'staff',
          type: _typeFromAnnouncement(item),
          priority: item.priorityLabel.toLowerCase(),
          isPinned: item.isPinned,
          createdAt: item.publishedAt,
          updatedAt: item.publishedAt,
          commentsCount: 0,
          reactionsCount: 0,
          attachmentLabel: null,
          comments: const <AnnouncementCommentItem>[],
          statusLabel: item.isPinned ? 'Pinned' : 'Published',
        ),
      )
      .toList(growable: false);

  final postFeed = subjects
      .map((subject) => repository.subjectGroupById(subject.id, user))
      .expand(
        (group) => group.posts.map(
          (post) => _feedItemFromPost(
            group: group,
            post: post,
            localComments: localComments[post.id] ?? const <AnnouncementCommentItem>[],
          ),
        ),
      )
      .toList(growable: false);

  final feed = [...drafts.map((draft) => draft.toFeedItem()), ...announcementFeed, ...postFeed]
    ..sort((left, right) {
      final pinCompare = right.isPinned.toString().compareTo(left.isPinned.toString());
      if (pinCompare != 0) {
        return pinCompare;
      }
      return right.createdAt.compareTo(left.createdAt);
    });

  final activities = <AnnouncementActivityItem>[
    ...feed.take(4).map(
          (item) => AnnouncementActivityItem(
            title: item.title,
            subtitle: '${item.subjectCode} • ${item.authorName}',
            timestampLabel: _relativeTime(item.createdAt),
            icon: item.isPinned ? Icons.push_pin_rounded : Icons.campaign_rounded,
            color: item.isUrgent ? const Color(0xFFDC2626) : const Color(0xFF2563EB),
          ),
        ),
    ...postFeed
        .expand((item) => item.comments)
        .take(4)
        .map(
          (comment) => AnnouncementActivityItem(
            title: 'New comment from ${comment.authorName}',
            subtitle: comment.message,
            timestampLabel: _relativeTime(comment.createdAt),
            icon: Icons.chat_bubble_outline_rounded,
            color: const Color(0xFF8B5CF6),
          ),
        ),
  ];

  final unresolvedThreads = postFeed
      .where(
        (item) =>
            item.commentsCount > 1 &&
            item.comments.every((comment) => comment.authorRole.toLowerCase() == 'student'),
      )
      .take(4)
      .map(
        (item) => AnnouncementActivityItem(
          title: item.title,
          subtitle: '${item.commentsCount} student comments without staff follow-up',
          timestampLabel: _relativeTime(item.updatedAt),
          icon: Icons.mark_chat_unread_rounded,
          color: const Color(0xFFF59E0B),
        ),
      )
      .toList(growable: false);

  final studentQuestions = postFeed
      .expand(
        (item) => item.comments
            .where((comment) => comment.authorRole.toLowerCase() == 'student')
            .map(
              (comment) => AnnouncementActivityItem(
                title: comment.authorName,
                subtitle: comment.message,
                timestampLabel: _relativeTime(comment.createdAt),
                icon: Icons.help_outline_rounded,
                color: const Color(0xFF0EA5E9),
              ),
            ),
      )
      .take(4)
      .toList(growable: false);

  return AnnouncementsWorkspaceData(
    subjects: subjects,
    feed: feed,
    activity: activities,
    unresolvedThreads: unresolvedThreads,
    studentQuestions: studentQuestions,
  );
}

List<AnnouncementFeedItem> filterFeedItems(
  List<AnnouncementFeedItem> items,
  AnnouncementFeedFilter filter,
) {
  return switch (filter) {
    AnnouncementFeedFilter.all => items,
    AnnouncementFeedFilter.mySubjects => items,
    AnnouncementFeedFilter.urgent =>
      items.where((item) => item.isUrgent).toList(growable: false),
    AnnouncementFeedFilter.pinned =>
      items.where((item) => item.isPinned).toList(growable: false),
    AnnouncementFeedFilter.recent => items
        .where(
          (item) => DateTime(2026, 4, 23, 12).difference(item.createdAt).inDays <= 2,
        )
        .toList(growable: false),
  };
}

AnnouncementFeedItem _feedItemFromPost({
  required SubjectGroupModel group,
  required GroupPostModel post,
  required List<AnnouncementCommentItem> localComments,
}) {
  final mergedComments = [
    ...post.comments.map(
      (comment) => AnnouncementCommentItem(
        id: comment.id,
        authorName: comment.authorName,
        authorRole: comment.authorRole,
        message: comment.message,
        createdAt: comment.createdAt,
      ),
    ),
    ...localComments,
  ];

  return AnnouncementFeedItem(
    id: post.id,
    subjectId: group.subjectId,
    subjectCode: group.subjectCode,
    subjectName: group.subjectName,
    title: post.title.isEmpty ? '${group.subjectCode} update' : post.title,
    content: post.content,
    authorName: post.authorName,
    authorRole: post.authorRole,
    type: post.type,
    priority: post.priority,
    isPinned: post.isPinned,
    createdAt: post.createdAt,
    updatedAt: post.updatedAt,
    commentsCount: mergedComments.length,
    reactionsCount: post.reactionsCount,
    attachmentLabel: post.attachmentLabel,
    comments: mergedComments,
    statusLabel: post.isPinned ? 'Pinned' : 'Published',
  );
}

String _typeFromAnnouncement(MockAnnouncementItem item) {
  final title = item.title.toLowerCase();
  if (title.contains('quiz')) {
    return 'Quiz alert';
  }
  if (title.contains('lecture') || title.contains('room')) {
    return 'Lecture update';
  }
  return 'Announcement';
}

String _relativeTime(DateTime dateTime) {
  final now = DateTime(2026, 4, 23, 12, 0);
  final difference = now.difference(dateTime);
  if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m ago';
  }
  if (difference.inHours < 24) {
    return '${difference.inHours}h ago';
  }
  return '${difference.inDays}d ago';
}
