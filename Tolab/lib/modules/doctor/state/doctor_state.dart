import '../../../academy_panel/models/academy_models.dart';

class DoctorState {
  const DoctorState({
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

  DoctorState copyWith({
    String? currentPageKey,
    PanelLoadStatus? status,
    Map<String, RolePageData>? pages,
    List<AcademyNotificationItem>? notifications,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DoctorState(
      currentPageKey: currentPageKey ?? this.currentPageKey,
      status: status ?? this.status,
      pages: pages ?? this.pages,
      notifications: notifications ?? this.notifications,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  factory DoctorState.initial() {
    return const DoctorState(
      currentPageKey: 'dashboard',
      status: PanelLoadStatus.initial,
      pages: {},
      notifications: [],
    );
  }
}
