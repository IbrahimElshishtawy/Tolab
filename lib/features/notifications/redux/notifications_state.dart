class NotificationsState {
  final bool isLoading;
  final List<dynamic>? notifications;
  NotificationsState({required this.isLoading, this.notifications});
  factory NotificationsState.initial() => NotificationsState(isLoading: false);

  NotificationsState copyWith({required List<dynamic> notifications}) {
    return NotificationsState(
      isLoading: isLoading,
      notifications: notifications,
    );
  }
}
