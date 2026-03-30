import 'package:redux/redux.dart';

import '../../app/core/services/app_dependencies.dart';
import '../../modules/admin/repositories/admin_repository.dart';
import '../../modules/admin/services/admin_api_service.dart';
import '../../modules/admin/state/admin_middleware.dart';
import '../../modules/doctor/repositories/doctor_repository.dart';
import '../../modules/doctor/services/doctor_api_service.dart';
import '../../modules/doctor/state/doctor_middleware.dart';
import '../../modules/student/repositories/student_repository.dart';
import '../../modules/student/services/student_api_service.dart';
import '../../modules/student/state/student_middleware.dart';
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
