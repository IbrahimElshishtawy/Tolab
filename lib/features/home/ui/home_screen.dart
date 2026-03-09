import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../../../redux/app_state.dart';
import '../presentation/screens/student_home_screen.dart';
import '../presentation/screens/doctor_home_screen.dart';
import '../presentation/screens/ta_home_screen.dart';
import '../presentation/screens/it_home_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, String?>(
      converter: (store) => store.state.authState.role,
      builder: (context, role) {
        switch (role?.toUpperCase()) {
          case 'DOCTOR':
          case 'PROFESSOR':
            return const DoctorHomeScreen();
          case 'TA':
          case 'ASSISTANT':
            return const TaHomeScreen();
          case 'IT':
          case 'ADMIN':
            return const ItHomeScreen();
          default:
            return const StudentHomeContent();
        }
      },
    );
  }
}
