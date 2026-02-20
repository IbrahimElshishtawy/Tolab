class NotificationsState {
  final bool isLoading;
  NotificationsState({required this.isLoading});
  factory NotificationsState.initial() => NotificationsState(isLoading: false);
}
