import '../../../academy_panel/models/academy_models.dart';

class StudentState {
  const StudentState({
    required this.currentPageKey,
    required this.status,
    required this.pages,
    required this.notifications,
    this.errorMessage,
  });

  final String currentPageKey;
  final PanelLoadStatus status;
  final Map<String, RolePageData> pages;
  final List<AcademyNotificationItem> notifications;
  final String? errorMessage;

  int get unreadCount => notifications.where((item) => !item.isRead).length;

  RolePageData? pageFor(String key) => pages[key];

  StudentState copyWith({
    String? currentPageKey,
    PanelLoadStatus? status,
    Map<String, RolePageData>? pages,
    List<AcademyNotificationItem>? notifications,
    String? errorMessage,
    bool clearError = false,
  }) {
    return StudentState(
      currentPageKey: currentPageKey ?? this.currentPageKey,
      status: status ?? this.status,
      pages: pages ?? this.pages,
      notifications: notifications ?? this.notifications,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  factory StudentState.initial() {
    return const StudentState(
      currentPageKey: 'dashboard',
      status: PanelLoadStatus.initial,
      pages: {},
      notifications: [],
    );
  }
}
