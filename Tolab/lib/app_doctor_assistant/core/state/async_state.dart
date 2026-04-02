enum ViewStatus { initial, loading, success, failure }

class AsyncState<T> {
  const AsyncState({
    this.status = ViewStatus.initial,
    this.data,
    this.error,
  });

  final ViewStatus status;
  final T? data;
  final String? error;

  AsyncState<T> copyWith({
    ViewStatus? status,
    T? data,
    String? error,
    bool clearError = false,
  }) {
    return AsyncState<T>(
      status: status ?? this.status,
      data: data ?? this.data,
      error: clearError ? null : error ?? this.error,
    );
  }
}
