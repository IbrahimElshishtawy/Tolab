class ContentItem {
  const ContentItem({
    required this.id,
    required this.courseTitle,
    required this.type,
    required this.title,
    required this.status,
    required this.attachments,
    this.dueDateLabel,
  });

  final String id;
  final String courseTitle;
  final String type;
  final String title;
  final String status;
  final int attachments;
  final String? dueDateLabel;
}

class UploadItem {
  const UploadItem({
    required this.id,
    required this.name,
    required this.sizeLabel,
    required this.progress,
    required this.status,
    required this.mimeType,
  });

  final String id;
  final String name;
  final String sizeLabel;
  final double progress;
  final String status;
  final String mimeType;
}
