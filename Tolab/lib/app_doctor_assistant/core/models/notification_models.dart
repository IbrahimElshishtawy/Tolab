class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.isRead,
    required this.createdAt,
  });

  final int id;
  final String title;
  final String body;
  final String category;
  final bool isRead;
  final String createdAt;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      isRead: json['is_read'] == true,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

class UploadModel {
  const UploadModel({
    required this.id,
    required this.name,
    required this.mimeType,
    required this.sizeLabel,
    required this.url,
  });

  final int id;
  final String name;
  final String mimeType;
  final String sizeLabel;
  final String url;

  factory UploadModel.fromJson(Map<String, dynamic> json) {
    return UploadModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      mimeType: json['mime_type']?.toString() ?? '',
      sizeLabel: json['size_label']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
    );
  }
}

class ScheduleEventModel {
  const ScheduleEventModel({
    required this.id,
    required this.title,
    required this.eventType,
    required this.eventDate,
    required this.colorKey,
    this.startTime,
    this.endTime,
    this.location,
  });

  final int id;
  final String title;
  final String eventType;
  final String eventDate;
  final String colorKey;
  final String? startTime;
  final String? endTime;
  final String? location;

  factory ScheduleEventModel.fromJson(Map<String, dynamic> json) {
    return ScheduleEventModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      eventType: json['event_type']?.toString() ?? '',
      eventDate: json['event_date']?.toString() ?? '',
      colorKey: json['color_key']?.toString() ?? 'default',
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
      location: json['location']?.toString(),
    );
  }
}
