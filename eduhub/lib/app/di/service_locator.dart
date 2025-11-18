import 'package:eduhub/features/auth/data/datasources/auth_fake_datasource.dart';
import 'package:eduhub/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:eduhub/features/auth/domain/repositories/auth_repository.dart';
import 'package:eduhub/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:eduhub/features/auth/domain/usecases/login_usecase.dart';
import 'package:eduhub/features/auth/domain/usecases/logout_usecase.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // DataSources
  sl.registerLazySingleton<AuthFakeDataSource>(() => AuthFakeDataSource());

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () =>
        AuthRepositoryImpl(sl<AuthFakeDataSource>(), remote: sl(), local: sl()),
  );
  // UseCases
  sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LogoutUseCase(sl<AuthRepository>()));
}
