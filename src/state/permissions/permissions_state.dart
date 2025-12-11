class permissionsState {
  final bool isLoading;
  final dynamic data;
  final String? error;

  permissionsState({
    required this.isLoading,
    required this.data,
    this.error,
  });

  factory permissionsState.initial() =>
      permissionsState(isLoading: false, data: null);

  permissionsState copyWith({bool? isLoading, dynamic data, String? error}) {
    return permissionsState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      error: error,
    );
  }
}
