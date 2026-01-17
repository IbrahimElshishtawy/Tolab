import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:tolab_fci/app/Router_ViewModel.dart';
import 'package:tolab_fci/features/splash/splash_route.dart';

import '../redux/state/app_state.dart';

// Screens
import '../features/splash/presentation/screens/splash_screen.dart';
import '../features/splash/presentation/screens/intro_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, RouterViewModel>(
      distinct: true,
      converter: (store) => RouterViewModel.fromStore(store),
      builder: (context, vm) {
        // أثناء تسجيل الدخول
        if (vm.isLoading) {
          return SplashRoute.splash;
        }

        //  مش مسجّل
        if (!vm.isAuthenticated) {
          return const LoginScreen();
        }

        //  مسجّل – نوجّه حسب الدور
        // switch (vm.role) {
        //   case 'student':
        //     return const HomeScreen();

        //   case 'doctor':
        //     return const HomeScreen(); // لاحقًا DoctorDashboard

        //   case 'ta':
        //     return const HomeScreen(); // لاحقًا TADashboard

        //   case 'it':
        //     return const HomeScreen(); // لاحقًا AdminPanel

        //   default:
        //     return const LoginScreen();
        // }
        return const HomeScreen();
      },
    );
  }
}
