import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:redux/redux.dart';
import 'package:tolab_fci/features/auth/data/repositories/auth_repository.dart';
import 'package:tolab_fci/features/auth/data/repositories/auth_repository_impl.dart';

import '../redux/middlewares/auth_middleware.dart';
import '../features/auth/data/datasources/auth_remote_ds.dart';
import '../features/auth/data/datasources/auth_role_ds.dart';
import '../redux/state/app_state.dart';

List<Middleware<AppState>> createAppMiddlewares() {
  // ===============================
  // Firebase instances
  // ===============================
  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  // ===============================
  // Data Sources
  // ===============================
  final authRemoteDS = AuthRemoteDataSourceImpl(firebaseAuth);

  final authRoleDS = AuthRoleDataSourceImpl(firestore);

  // ===============================
  // Repository
  // ===============================
  final AuthRepository authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDS,
    roleDataSource: authRoleDS,
  );

  // ===============================
  // Middlewares
  // ===============================
  return [...createAuthMiddleware(authRepository)];
}
