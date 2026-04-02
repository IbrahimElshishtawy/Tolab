import '../../../core/state/async_state.dart';

class BootstrapState {
  const BootstrapState({
    this.status = ViewStatus.initial,
    this.error,
  });

  final ViewStatus status;
  final String? error;

  BootstrapState copyWith({
    ViewStatus? status,
    String? error,
    bool clearError = false,
  }) {
    return BootstrapState(
      status: status ?? this.status,
      error: clearError ? null : error ?? this.error,
    );
  }
}
