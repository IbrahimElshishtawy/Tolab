import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:redux/redux.dart';
import 'package:tolab_fci/features/auth/data/datasources/auth_remote_ds.dart';
import 'package:tolab_fci/features/auth/data/datasources/auth_role_ds.dart';
import 'package:tolab_fci/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:tolab_fci/redux/middlewares/auth_listener_middleware.dart';
import 'package:tolab_fci/redux/middlewares/auth_middleware.dart';
import 'package:tolab_fci/redux/reducers/root_reducer.dart';
import 'package:tolab_fci/redux/state/app_state.dart';

Store<AppState> createStore() {
  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  final remoteDS = AuthRemoteDataSourceImpl(firebaseAuth);
  final roleDS = AuthRoleDataSourceImpl(firestore);

  final authRepository = AuthRepositoryImpl(
    remoteDataSource: remoteDS,
    roleDataSource: roleDS,
  );

  return Store<AppState>(
    appReducer,
    initialState: AppState.initial(),
    middleware: [
      ...createAuthMiddleware(authRepository),
      createAuthListenerMiddleware(firebaseAuth),
    ],
  );
}
