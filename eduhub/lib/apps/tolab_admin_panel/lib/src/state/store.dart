import 'package:eduhub/apps/tolab_admin_panel/lib/src/core/api/Api_Service_auth.dart';
import 'package:eduhub/apps/tolab_admin_panel/lib/src/core/api/Api_Service_dashhoard.dart';
import 'package:eduhub/apps/tolab_admin_panel/lib/src/core/api/api_service_assistants.dart';
import 'package:eduhub/apps/tolab_admin_panel/lib/src/core/api/api_service_doctors.dart';
import 'package:eduhub/apps/tolab_admin_panel/lib/src/core/api/api_service_students.dart';
import 'package:eduhub/apps/tolab_admin_panel/lib/src/state/assistants/assistants_middleware.dart';
import 'package:eduhub/apps/tolab_admin_panel/lib/src/state/dashboard/dashboard_middleware.dart';
import 'package:eduhub/apps/tolab_admin_panel/lib/src/state/doctors/doctors_middleware.dart';
import 'package:eduhub/apps/tolab_admin_panel/lib/src/state/students/students_middleware.dart';
import 'package:redux/redux.dart';
import 'app_state.dart';
import 'reducers/app_reducer.dart';
import 'auth/auth_middleware.dart';

Store<AppState> createStore() {
  final apiAuth = ApiServiceAuth();
  final apiDashhoard = ApiServiceDashboard();
  final apiAssistants = ApiServiceAssistants();
  final apiDoctors = ApiServiceDoctors();
  final apiStudents = ApiServiceStudents();
  return Store<AppState>(
    appReducer,
    initialState: AppState.initial(),
    middleware: [
      ...authMiddleware(apiAuth),
      ...dashboardMiddleware(apiDashhoard),
      ...createAssistantsMiddleware(apiAssistants),
      ...createDoctorsMiddleware(apiDoctors),
      ...createStudentsMiddleware(apiStudents),
    ],
  );
}
