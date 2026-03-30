import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:redux/redux.dart';

import '../../modules/admin/models/admin_models.dart';
import '../../modules/admin/presentation/pages/admin_workspace_page.dart';
import '../../modules/admin/state/admin_actions.dart';
import '../../modules/doctor/models/doctor_models.dart';
import '../../modules/doctor/presentation/pages/doctor_workspace_page.dart';
import '../../modules/doctor/state/doctor_actions.dart';
import '../../modules/student/models/student_models.dart';
import '../../modules/student/presentation/pages/student_workspace_page.dart';
import '../../modules/student/state/student_actions.dart';
import '../models/academy_models.dart';
import '../state/academy_state.dart';
import '../widgets/login_page.dart';

class AcademyRouter {
  AcademyRouter(this._store) {
    router = GoRouter(
      initialLocation: '/login',
      refreshListenable: _StoreRefreshListenable(_store),
      redirect: (context, state) {
        final session = _store.state.session;
        final isLogin = state.uri.path == '/login';
        if (!session.isAuthenticated) {
          return isLogin ? null : '/login';
        }
        final role = session.user!.role;
        if (isLogin) {
          return '/${role.routeSegment}/dashboard';
        }
        if (!state.uri.path.startsWith('/${role.routeSegment}/')) {
          return '/${role.routeSegment}/dashboard';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const AcademyLoginPage(),
        ),
        GoRoute(
          path: '/admin/:page',
          pageBuilder: (context, state) {
            final page = _pageKey(
              state.pathParameters['page'],
              adminNavigationItems,
            );
            _store.dispatch(AdminNavigateAction(page));
            _store.dispatch(AdminLoadPageAction(page));
            return _transitionPage(state, AdminWorkspacePage(pageKey: page));
          },
        ),
        GoRoute(
          path: '/student/:page',
          pageBuilder: (context, state) {
            final page = _pageKey(
              state.pathParameters['page'],
              studentNavigationItems,
            );
            _store.dispatch(StudentNavigateAction(page));
            _store.dispatch(StudentLoadPageAction(page));
            return _transitionPage(state, StudentWorkspacePage(pageKey: page));
          },
        ),
        GoRoute(
          path: '/doctor/:page',
          pageBuilder: (context, state) {
            final page = _pageKey(
              state.pathParameters['page'],
              doctorNavigationItems,
            );
            _store.dispatch(DoctorNavigateAction(page));
            _store.dispatch(DoctorLoadPageAction(page));
            return _transitionPage(state, DoctorWorkspacePage(pageKey: page));
          },
        ),
      ],
    );
  }

  final Store<AcademyAppState> _store;
  late final GoRouter router;

  String _pageKey(String? value, List<RoleNavItem> items) {
    final candidate = value?.trim().toLowerCase();
    if (candidate == null || candidate.isEmpty) return items.first.key;
    return items.any((item) => item.key == candidate)
        ? candidate
        : items.first.key;
  }

  CustomTransitionPage<void> _transitionPage(
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.02, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _StoreRefreshListenable extends ChangeNotifier {
  _StoreRefreshListenable(Store<AcademyAppState> store) {
    _isAuthenticated = store.state.session.isAuthenticated;
    _role = store.state.session.user?.role;
    _subscription = store.onChange.listen((state) {
      final nextAuthenticated = state.session.isAuthenticated;
      final nextRole = state.session.user?.role;
      if (nextAuthenticated == _isAuthenticated && nextRole == _role) {
        return;
      }
      _isAuthenticated = nextAuthenticated;
      _role = nextRole;
      notifyListeners();
    });
  }

  late final StreamSubscription<AcademyAppState> _subscription;
  late bool _isAuthenticated;
  AcademyRole? _role;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
