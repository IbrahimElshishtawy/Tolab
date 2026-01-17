// ignore_for_file: file_names

import 'package:redux/redux.dart';
import '../redux/state/app_state.dart';

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
    final auth = store.state.authState;
    final ui = store.state.uiState;

    return RouterViewModel(
      isAuthenticated: auth.isAuthenticated,
      isLoading: auth.isLoading,
      role: auth.role,
      showSplash: ui.showSplash,
      showIntro: ui.showIntro,
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
