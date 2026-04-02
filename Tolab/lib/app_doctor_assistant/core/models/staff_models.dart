import 'session_user.dart';

class StaffMemberModel {
  const StaffMemberModel({
    required this.user,
    required this.departmentName,
    required this.assignmentSummary,
  });

  final SessionUser user;
  final String departmentName;
  final String assignmentSummary;

  factory StaffMemberModel.fromJson(Map<String, dynamic> json) {
    return StaffMemberModel(
      user: SessionUser.fromJson(
        Map<String, dynamic>.from(json['user'] as Map? ?? const {}),
      ),
      departmentName: json['department_name']?.toString() ?? '',
      assignmentSummary: json['assignment_summary']?.toString() ?? '',
    );
  }
}
