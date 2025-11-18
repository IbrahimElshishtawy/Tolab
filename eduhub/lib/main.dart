// main.dart أو app.dart

import 'package:eduhub/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/di/service_locator.dart';

import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/get_current_user_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
// import router ...

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(
        loginUseCase: sl<LoginUseCase>(),
        getCurrentUserUseCase: sl<GetCurrentUserUseCase>(),
        logoutUseCase: sl<LogoutUseCase>(),
      )..checkAuthStatus(), // أول ما يفتح الابلكيشن
      child: MaterialApp(
        title: 'Center Management',
        // theme, routes, router, ...
        home: const SplashPage(),
      ),
    );
  }
}
