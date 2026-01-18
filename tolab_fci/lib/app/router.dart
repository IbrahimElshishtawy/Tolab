import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:tolab_fci/app/Router_ViewModel.dart';
import 'package:tolab_fci/features/auth/presentation/screens/login_screen.dart';
import 'package:tolab_fci/features/home/presentation/screens/doctor_home_screen.dart';
import 'package:tolab_fci/features/home/presentation/screens/it_home_screen.dart';
import 'package:tolab_fci/features/home/presentation/screens/student_home_screen.dart';
import 'package:tolab_fci/features/home/presentation/screens/ta_home_screen.dart';
import 'package:tolab_fci/features/splash/presentation/screens/intro_screen.dart';
import 'package:tolab_fci/features/splash/presentation/screens/splash_screen.dart';
import 'package:tolab_fci/redux/state/app_state.dart';

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, RouterViewModel>(
      distinct: true,
      converter: (store) => RouterViewModel.fromStore(store),
      builder: (context, vm) {
        // 1️Splash
        if (vm.showSplash) {
          return const SplashScreen();
        }

        // 2️ Intro
        if (vm.showIntro) {
          return const IntroScreen();
        }

        // 3️ Loading أثناء Auth
        if (vm.isLoading) {
          return const SplashScreen();
        }

        // 4️ Login
        if (!vm.isAuthenticated) {
          return const LoginScreen();
        }
        //`  Role غير محدد
        if (vm.isAuthenticated && vm.role == null) {
          return const LoginScreen();
        }

        // 5️ Home حسب الدور
        switch (vm.role) {
          case 'student':
            return const StudentHomeScreen();

          case 'doctor':
            return const DoctorHomeScreen();

          case 'ta':
            return const TaHomeScreen();

          case 'it':
            return const ItHomeScreen();

          default:
            return const LoginScreen();
        }
      },
    );
  }
}
