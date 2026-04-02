import '../../../core/models/academic_models.dart';

class LoadAdminOverviewAction {}

class LoadAdminOverviewSuccessAction {
  LoadAdminOverviewSuccessAction(this.data);

  final Map<String, dynamic> data;
}

class LoadPermissionsAction {}

class LoadPermissionsSuccessAction {
  LoadPermissionsSuccessAction(this.items);

  final List<String> items;
}

class LoadDepartmentsAction {}

class LoadDepartmentsSuccessAction {
  LoadDepartmentsSuccessAction(this.items);

  final List<DepartmentModel> items;
}

class AdminFailureAction {
  AdminFailureAction(this.message);

  final String message;
}

class ToggleStaffActivationAction {
  ToggleStaffActivationAction({
    required this.userId,
    required this.isActive,
  });

  final int userId;
  final bool isActive;
}
