import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../../../redux/app_state.dart';
import 'widgets/student_widgets.dart';
import 'widgets/educator_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, String?>(
      converter: (store) => store.state.authState.role,
      builder: (context, role) {
        return Scaffold(
          appBar: AppBar(
            title: Text(role == 'student' ? 'Student Home' : (role == 'doctor' ? 'Doctor Home' : 'Assistant Home')),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                if (role == 'student') ...[
                  const EnrolledCourses(),
                  const UpcomingDeadlines(),
                ] else if (role == 'doctor') ...[
                  const DoctorHomeDashboard(),
                ] else if (role == 'assistant') ...[
                  const AssistantHomeDashboard(),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
