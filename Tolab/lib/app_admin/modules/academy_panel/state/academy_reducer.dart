import '../../admin/state/admin_reducer.dart';
import '../../doctor/state/doctor_reducer.dart';
import '../../student/state/student_reducer.dart';
import 'academy_actions.dart';
import 'academy_state.dart';

AcademyAppState academyReducer(AcademyAppState state, dynamic action) {
  return AcademyAppState(
    session: academySessionReducer(state.session, action),
    themeMode: academyThemeReducer(state.themeMode, action),
    toastQueue: academyToastReducer(state.toastQueue, action),
    adminState: adminReducer(state.adminState, action),
    studentState: studentReducer(state.studentState, action),
    doctorState: doctorReducer(state.doctorState, action),
  );
}
