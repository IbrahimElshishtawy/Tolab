import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:redux/redux.dart';

import '../../app_admin/core/services/app_dependencies.dart' as admin_deps;
import '../../app_admin/modules/auth/state/auth_state.dart' as admin_auth;
import '../../app_admin/state/app_state.dart' as admin_state;
import '../../app_admin/state/store.dart' as admin_store;
import '../../app_doctor_assistant/core/services/app_dependencies.dart'
    as doctor_deps;
import '../../app_doctor_assistant/modules/auth/state/session_actions.dart';
import '../../app_doctor_assistant/state/app_state.dart' as doctor_state;
import '../../app_doctor_assistant/state/store.dart' as doctor_store;
import '../auth/repositories/auth_repository.dart';
import '../auth/services/session_storage.dart';
import '../auth/state/auth_controller.dart';
import '../shared/theme_mode_controller.dart';

class UnifiedAppBootstrap {
  UnifiedAppBootstrap._({
    required this.adminDependencies,
    required this.doctorDependencies,
    required this.adminStore,
    required this.doctorStore,
    required this.authController,
    required this.themeController,
    required VoidCallback legacySyncListener,
  }) : _legacySyncListener = legacySyncListener;

  final admin_deps.AppDependencies adminDependencies;
  final doctor_deps.AppDependencies doctorDependencies;
  final Store<admin_state.AppState> adminStore;
  final Store<doctor_state.DoctorAssistantAppState> doctorStore;
  final AuthController authController;
  final ThemeModeController themeController;
  final VoidCallback _legacySyncListener;

  static Future<UnifiedAppBootstrap> initialize() async {
    final adminDependencies = await admin_deps.AppDependencies.initialize();
    final doctorDependencies = await doctor_deps.AppDependencies.initialize();

    final adminStore = admin_store.createAppStore(adminDependencies);
    final doctorStore = doctor_store.createDoctorAssistantStore(
      doctorDependencies,
    );

    final authRepository = UnifiedAuthRepository(
      doctorRepository: doctorDependencies.authRepository,
      adminDependencies: adminDependencies,
      doctorTokenStorage: doctorDependencies.tokenStorage,
      sessionStorage: SessionStorage(),
    );
    final authController = AuthController(authRepository);
    final themeController = ThemeModeController();

    void syncLegacyStores() {
      final session = authController.state.session;
      if (session == null) {
        adminStore.dispatch(admin_auth.LogoutCompletedAction());
        doctorStore.dispatch(const SessionClearedAction());
        return;
      }

      adminStore.dispatch(admin_auth.HydrateUserAction(session.user.toAdminProfile()));
      doctorStore.dispatch(SessionEstablishedAction(session.user.toSessionUser()));
    }

    authController.addListener(syncLegacyStores);
    await authController.bootstrap();

    return UnifiedAppBootstrap._(
      adminDependencies: adminDependencies,
      doctorDependencies: doctorDependencies,
      adminStore: adminStore,
      doctorStore: doctorStore,
      authController: authController,
      themeController: themeController,
      legacySyncListener: syncLegacyStores,
    );
  }

  Future<void> dispose() async {
    authController.removeListener(_legacySyncListener);
    authController.dispose();
    themeController.dispose();
    await adminDependencies.notificationService.dispose();
  }
}
