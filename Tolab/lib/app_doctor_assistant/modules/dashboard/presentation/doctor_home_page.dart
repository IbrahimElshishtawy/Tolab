import 'package:flutter/material.dart';

import '../../../core/models/session_user.dart';
import '../state/dashboard_view_model.dart';
import 'doctor_dashboard_page.dart';

class DoctorHomePage extends StatelessWidget {
  const DoctorHomePage({
    super.key,
    required this.user,
    required this.vm,
    required this.onToggleStyle,
  });

  final SessionUser user;
  final DashboardViewModel vm;
  final VoidCallback onToggleStyle;

  @override
  Widget build(BuildContext context) {
    return DoctorDashboardPage(
      user: user,
      vm: vm,
      onToggleStyle: onToggleStyle,
    );
  }
}
