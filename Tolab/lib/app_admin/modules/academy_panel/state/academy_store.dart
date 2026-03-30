import 'package:redux/redux.dart';

import '../../../core/services/app_dependencies.dart';
import '../../admin/repositories/admin_repository.dart';
import '../../admin/services/admin_api_service.dart';
import '../../admin/state/admin_middleware.dart';
import '../../doctor/repositories/doctor_repository.dart';
import '../../doctor/services/doctor_api_service.dart';
import '../../doctor/state/doctor_middleware.dart';
import '../../student/repositories/student_repository.dart';
import '../../student/services/student_api_service.dart';
import '../../student/state/student_middleware.dart';
import 'academy_middleware.dart';
import 'academy_reducer.dart';
import 'academy_state.dart';

Store<AcademyAppState> createAcademyStore(AppDependencies dependencies) {
  final adminRepository = AdminRepository(
    AdminApiService(dependencies.apiClient),
  );
  final studentRepository = StudentRepository(
    StudentApiService(dependencies.apiClient),
  );
  final doctorRepository = DoctorRepository(
    DoctorApiService(dependencies.apiClient),
  );

  return Store<AcademyAppState>(
    academyReducer,
    initialState: AcademyAppState.initial(),
    middleware: [
      ...createAcademyMiddleware(dependencies),
      ...createAdminMiddleware(adminRepository),
      ...createStudentMiddleware(studentRepository),
      ...createDoctorMiddleware(doctorRepository),
    ],
  );
}
