// post_model.dart

class PostModel {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final String? authorRole;
  final String? year;
  final String? term;
  final String? date;
  final DateTime createdAt;
  final int views;
  final int shares;
  final int? viewsCount;
  final int? shareCount;
  final bool? isApproved;
  final bool? pending;
  final List<String> viewsUsers;

  PostModel({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    this.authorRole,
    this.year,
    this.term,
    this.date,
    required this.createdAt,
    required this.views,
    required this.shares,
    this.viewsCount,
    this.shareCount,
    this.isApproved,
    this.pending,
    required this.viewsUsers,
  });

  PostModel copyWith({
    String? id,
    String? title,
    String? content,
    String? authorId,
    String? authorName,
    String? authorRole,
    String? year,
    String? term,
    String? date,
    DateTime? createdAt,
    int? views,
    int? shares,
    int? viewsCount,
    int? shareCount,
    bool? isApproved,
    bool? pending,
    List<String>? viewsUsers,
  }) {
    return PostModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorRole: authorRole ?? this.authorRole,
      year: year ?? this.year,
      term: term ?? this.term,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      views: views ?? this.views,
      shares: shares ?? this.shares,
      viewsCount: viewsCount ?? this.viewsCount,
      shareCount: shareCount ?? this.shareCount,
      isApproved: isApproved ?? this.isApproved,
      pending: pending ?? this.pending,
      viewsUsers: viewsUsers ?? this.viewsUsers,
    );
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      authorRole: map['authorRole'],
      year: map['year'],
      term: map['term'],
      date: map['date'],
      createdAt: DateTime.parse(map['createdAt']),
      views: map['views'] ?? 0,
      shares: map['shares'] ?? 0,
      viewsCount: map['viewsCount'],
      shareCount: map['shareCount'],
      isApproved: map['isApproved'],
      pending: map['pending'],
      viewsUsers: List<String>.from(map['viewsUsers'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'authorRole': authorRole,
      'year': year,
      'term': term,
      'date': date,
      'createdAt': createdAt.toIso8601String(),
      'views': views,
      'shares': shares,
      'viewsCount': viewsCount,
      'shareCount': shareCount,
      'isApproved': isApproved,
      'pending': pending,
      'viewsUsers': viewsUsers,
    };
  }

  static fromJson(Map<String, dynamic> map) {
    return PostModel.fromMap(map);
  }
}
