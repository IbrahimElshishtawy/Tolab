// ignore_for_file: file_names

import 'package:flutter/foundation.dart';
import 'package:redux/redux.dart';
import 'package:tolab_fci/redux/selectors/auth_selectors.dart';
import 'package:tolab_fci/redux/state/app_state.dart';

class RouterViewModel {
  final bool isAuthenticated;
  final bool isLoading;
  final String? role;

  // UI flow flags
  final bool showSplash;
  final bool showIntro;

  RouterViewModel({
    required this.isAuthenticated,
    required this.isLoading,
    required this.role,
    required this.showSplash,
    required this.showIntro,
  });

  factory RouterViewModel.fromStore(Store<AppState> store) {
    final state = store.state;

    debugPrint(
      '🧭 VM => auth=${state.authState.isAuthenticated}, '
      'loading=${state.authState.isLoading}, '
      'role=${state.authState.role}',
    );

    return RouterViewModel(
      isAuthenticated: selectIsAuthenticated(state),
      isLoading: selectAuthLoading(state),
      role: selectUserRole(state),
      showSplash: state.uiState.showSplash,
      showIntro: state.uiState.showIntro,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RouterViewModel &&
          isAuthenticated == other.isAuthenticated &&
          isLoading == other.isLoading &&
          role == other.role &&
          showSplash == other.showSplash &&
          showIntro == other.showIntro;

  @override
  int get hashCode =>
      isAuthenticated.hashCode ^
      isLoading.hashCode ^
      role.hashCode ^
      showSplash.hashCode ^
      showIntro.hashCode;
}
