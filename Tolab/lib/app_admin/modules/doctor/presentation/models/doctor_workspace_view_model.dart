import '../../../academy_panel/models/academy_models.dart';

class DoctorWorkspaceViewModel {
  const DoctorWorkspaceViewModel({
    required this.user,
    required this.page,
    required this.status,
    required this.unreadCount,
    this.errorMessage,
  });

  final AcademyUser user;
  final RolePageData page;
  final PanelLoadStatus status;
  final int unreadCount;
  final String? errorMessage;
}
