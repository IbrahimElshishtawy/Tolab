import '../../../core/helpers/json_types.dart';
import '../../../core/network/api_client.dart';
import '../models/moderation_models.dart';

class ModerationApiService {
  ModerationApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ModerationGroup>> fetchGroups() {
    return _apiClient.get<List<ModerationGroup>>(
      '/admin/groups',
      decoder: (json) {
        return _asJsonList(json).map(_groupFromJson).toList(growable: false);
      },
    );
  }

  Future<List<ModerationPost>> fetchPosts() {
    return _apiClient.get<List<ModerationPost>>(
      '/admin/posts',
      decoder: (json) {
        return _asJsonList(json).map(_postFromJson).toList(growable: false);
      },
    );
  }

  Future<List<ModerationComment>> fetchComments() {
    return _apiClient.get<List<ModerationComment>>(
      '/admin/comments',
      decoder: (json) {
        return _asJsonList(json).map(_commentFromJson).toList(growable: false);
      },
    );
  }

  Future<List<ModerationMessage>> fetchMessages() {
    return _apiClient.get<List<ModerationMessage>>(
      '/admin/messages',
      decoder: (json) {
        return _asJsonList(json).map(_messageFromJson).toList(growable: false);
      },
    );
  }

  Future<List<ModerationReport>> fetchReports() {
    return _apiClient.get<List<ModerationReport>>(
      '/admin/reports',
      decoder: (json) {
        return _asJsonList(json).map(_reportFromJson).toList(growable: false);
      },
    );
  }

  Future<void> submitAction(ModerationActionCommand command) {
    return _apiClient.post<void>(
      '/admin/actions',
      data: command.toJson(),
      decoder: (_) {},
    );
  }

  List<JsonMap> _asJsonList(dynamic json) {
    if (json is List) {
      return json.whereType<JsonMap>().toList(growable: false);
    }
    if (json is JsonMap) {
      final nested = json['items'] ?? json['rows'] ?? json['results'] ?? json['data'];
      if (nested is List) {
        return nested.whereType<JsonMap>().toList(growable: false);
      }
    }
    return const <JsonMap>[];
  }

  ModerationGroup _groupFromJson(JsonMap json) {
    final moderatorIds = _stringList(
      json['moderator_ids'] ?? json['moderatorIds'] ?? json['moderators'],
    );
    final memberPreview = _stringList(
      json['member_preview'] ?? json['memberPreview'] ?? json['sample_members'],
    );

    return ModerationGroup(
      id: _stringOf(json, 'id'),
      name: _stringOf(json, 'name', fallbackKey: 'title'),
      description: _stringOf(json, 'description'),
      category: _stringOf(json, 'category', fallback: 'Community'),
      memberCount: _intOf(json, 'member_count', fallbackKey: 'membersCount'),
      moderatorsCount: _intOf(
        json,
        'moderators_count',
        fallback: moderatorIds.length,
      ),
      flaggedPostsCount: _intOf(
        json,
        'flagged_posts_count',
        fallbackKey: 'flaggedPostsCount',
      ),
      status: moderationStatusFromJson(
        _stringOf(json, 'status', fallback: 'pending'),
      ),
      lastActivityAt: _dateOf(
        json,
        'last_activity_at',
        fallbackKey: 'lastActivityAt',
      ),
      memberPreview: memberPreview,
      moderatorIds: moderatorIds,
    );
  }

  ModerationPost _postFromJson(JsonMap json) {
    final author = json['author'];
    final group = json['group'];

    return ModerationPost(
      id: _stringOf(json, 'id'),
      title: _stringOf(json, 'title'),
      bodyPreview: _stringOf(
        json,
        'body_preview',
        fallbackKey: 'excerpt',
        fallback: _stringOf(json, 'body'),
      ),
      authorId: author is JsonMap
          ? _stringOf(author, 'id')
          : _stringOf(json, 'author_id'),
      authorName: author is JsonMap
          ? _stringOf(author, 'name')
          : _stringOf(json, 'author_name', fallbackKey: 'author'),
      groupId: group is JsonMap
          ? _stringOf(group, 'id')
          : _stringOf(json, 'group_id'),
      groupName: group is JsonMap
          ? _stringOf(group, 'name')
          : _stringOf(json, 'group_name'),
      status: moderationStatusFromJson(
        _stringOf(json, 'status', fallback: 'pending'),
      ),
      reportsCount: _intOf(json, 'reports_count', fallbackKey: 'reportCount'),
      commentsCount: _intOf(
        json,
        'comments_count',
        fallbackKey: 'commentsCount',
      ),
      createdAt: _dateOf(json, 'created_at', fallbackKey: 'createdAt'),
      tags: _stringList(json['tags']),
    );
  }

  ModerationComment _commentFromJson(JsonMap json) {
    final author = json['author'];
    final post = json['post'];

    return ModerationComment(
      id: _stringOf(json, 'id'),
      postId: post is JsonMap ? _stringOf(post, 'id') : _stringOf(json, 'post_id'),
      postTitle: post is JsonMap
          ? _stringOf(post, 'title')
          : _stringOf(json, 'post_title'),
      authorId: author is JsonMap
          ? _stringOf(author, 'id')
          : _stringOf(json, 'author_id'),
      authorName: author is JsonMap
          ? _stringOf(author, 'name')
          : _stringOf(json, 'author_name', fallbackKey: 'author'),
      content: _stringOf(json, 'content', fallbackKey: 'body'),
      status: moderationStatusFromJson(
        _stringOf(json, 'status', fallback: 'pending'),
      ),
      reportsCount: _intOf(json, 'reports_count', fallbackKey: 'reportCount'),
      createdAt: _dateOf(json, 'created_at', fallbackKey: 'createdAt'),
    );
  }

  ModerationMessage _messageFromJson(JsonMap json) {
    final sender = json['sender'];
    final receiver = json['receiver'];

    return ModerationMessage(
      id: _stringOf(json, 'id'),
      senderId: sender is JsonMap
          ? _stringOf(sender, 'id')
          : _stringOf(json, 'sender_id'),
      senderName: sender is JsonMap
          ? _stringOf(sender, 'name')
          : _stringOf(json, 'sender_name'),
      receiverId: receiver is JsonMap
          ? _stringOf(receiver, 'id')
          : _stringOf(json, 'receiver_id'),
      receiverName: receiver is JsonMap
          ? _stringOf(receiver, 'name')
          : _stringOf(json, 'receiver_name'),
      content: _stringOf(json, 'content', fallbackKey: 'message'),
      status: moderationStatusFromJson(
        _stringOf(json, 'status', fallback: 'pending'),
      ),
      riskScore: _doubleOf(json, 'risk_score', fallbackKey: 'riskScore'),
      createdAt: _dateOf(json, 'created_at', fallbackKey: 'createdAt'),
    );
  }

  ModerationReport _reportFromJson(JsonMap json) {
    final reporter = json['reporter'];

    return ModerationReport(
      id: _stringOf(json, 'id'),
      contentId: _stringOf(
        json,
        'content_id',
        fallbackKey: 'target_id',
      ),
      contentType: _stringOf(
        json,
        'content_type',
        fallbackKey: 'type',
        fallback: 'Post',
      ),
      subjectTitle: _stringOf(
        json,
        'subject_title',
        fallbackKey: 'title',
        fallback: _stringOf(json, 'subject'),
      ),
      contentPreview: _stringOf(
        json,
        'content_preview',
        fallbackKey: 'preview',
      ),
      groupName: _stringOf(
        json,
        'group_name',
        fallback: _stringOf(json, 'group'),
      ),
      reporterName: reporter is JsonMap
          ? _stringOf(reporter, 'name')
          : _stringOf(json, 'reporter_name', fallbackKey: 'reporter'),
      reason: _stringOf(json, 'reason'),
      status: moderationStatusFromJson(
        _stringOf(json, 'status', fallback: 'pending'),
      ),
      createdAt: _dateOf(json, 'created_at', fallbackKey: 'createdAt'),
    );
  }

  String _stringOf(
    JsonMap json,
    String key, {
    String? fallbackKey,
    String fallback = '',
  }) {
    final value = json[key] ?? (fallbackKey != null ? json[fallbackKey] : null);
    return value?.toString() ?? fallback;
  }

  int _intOf(
    JsonMap json,
    String key, {
    String? fallbackKey,
    int fallback = 0,
  }) {
    final raw = json[key] ?? (fallbackKey != null ? json[fallbackKey] : null);
    return switch (raw) {
      int value => value,
      double value => value.round(),
      String value => int.tryParse(value) ?? fallback,
      _ => fallback,
    };
  }

  double _doubleOf(
    JsonMap json,
    String key, {
    String? fallbackKey,
    double fallback = 0,
  }) {
    final raw = json[key] ?? (fallbackKey != null ? json[fallbackKey] : null);
    return switch (raw) {
      double value => value,
      int value => value.toDouble(),
      String value => double.tryParse(value) ?? fallback,
      _ => fallback,
    };
  }

  DateTime _dateOf(
    JsonMap json,
    String key, {
    String? fallbackKey,
  }) {
    final raw = json[key] ?? (fallbackKey != null ? json[fallbackKey] : null);
    if (raw is String) {
      final parsed = DateTime.tryParse(raw);
      if (parsed != null) return parsed;
    }
    return DateTime.now();
  }

  List<String> _stringList(dynamic raw) {
    if (raw is List) {
      return raw.map((value) => value.toString()).toList(growable: false);
    }
    return const <String>[];
  }
}
