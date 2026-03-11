import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:tolab_fci/features/auth/ui/login_screen.dart';
import 'package:tolab_fci/features/splash/presentation/screens/intro_screen.dart';
import 'package:tolab_fci/redux/state/app_state.dart';
import 'Router_ViewModel.dart';

// Screens
import 'package:tolab_fci/features/splash/presentation/screens/splash_screen.dart';
import 'package:tolab_fci/features/home/presentation/screens/student_home_screen.dart';
import 'package:tolab_fci/features/home/presentation/screens/doctor_home_screen.dart';
import 'package:tolab_fci/features/home/presentation/screens/ta_home_screen.dart';
import 'package:tolab_fci/features/home/presentation/screens/it_home_screen.dart';

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, RouterViewModel>(
      distinct: false,
      converter: RouterViewModel.fromStore,
      builder: (context, vm) {
        debugPrint(
          '🧭 VM => splash=${vm.showSplash}, '
          'intro=${vm.showIntro}, '
          'auth=${vm.isAuthenticated}, '
          'role=${vm.role}',
        );

        Widget screen;

        // 🟣 Splash
        if (vm.showSplash) {
          screen = const SplashScreen();
        }
        // 🔵 Intro
        else if (vm.showIntro) {
          screen = const IntroScreen();
        }
        // 🔐 Login
        else if (!vm.isAuthenticated) {
          screen = const LoginScreen();
        }
        // ⏳ Authenticated but role loading
        else if (vm.role == null) {
          screen = const SplashScreen();
        }
        // 🏠 Student Home
        else if (vm.role == 'student') {
          screen = const StudentHomeScreen();
        }
        // 👨‍🏫 Doctor Home
        else if (vm.role == 'doctor') {
          screen = const DoctorHomeScreen();
        }
        // 🧑‍🏫 TA Home
        else if (vm.role == 'ta') {
          screen = const TaHomeScreen();
        }
        // 🛠 IT Home
        else if (vm.role == 'it') {
          screen = const ItHomeScreen();
        }
        // ❓ Fallback
        else {
          screen = const Scaffold(
            body: Center(child: Text('دور المستخدم غير معروف')),
          );
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 450),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: KeyedSubtree(
            key: ValueKey<String>(
              '${vm.showSplash}-${vm.showIntro}-${vm.isAuthenticated}-${vm.role}',
            ),
            child: screen,
          ),
        );
      },
    );
  }
}
