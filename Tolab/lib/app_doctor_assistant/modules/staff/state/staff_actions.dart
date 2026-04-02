import '../../../core/models/staff_models.dart';

class LoadStaffAction {}

class LoadStaffSuccessAction {
  LoadStaffSuccessAction(this.items);

  final List<StaffMemberModel> items;
}

class LoadStaffFailureAction {
  LoadStaffFailureAction(this.message);

  final String message;
}
