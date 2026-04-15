import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../staff_portal/presentation/pages/doctor_home_page.dart';
import 'student_home_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isStaff = ref.watch(isStaffUserProvider);
    return isStaff ? const DoctorHomePage() : const StudentHomePage();
  }
}
