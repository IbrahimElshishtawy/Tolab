import 'package:equatable/equatable.dart';

enum NotificationType { announcement, assignment, grade, schedule, system, message }

class NotificationEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final String? relatedEntityId;
  final String? relatedEntityType;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;
  final String? actionUrl;

  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.relatedEntityId,
    this.relatedEntityType,
    required this.isRead,
    required this.createdAt,
    this.readAt,
    this.actionUrl,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        message,
        type,
        relatedEntityId,
        relatedEntityType,
        isRead,
        createdAt,
        readAt,
        actionUrl,
      ];
}
