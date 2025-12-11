class DoctorsState {
  final bool isLoading;
  final List<Map<String, dynamic>> doctors;
  final String? error;

  DoctorsState({required this.isLoading, required this.doctors, this.error});

  factory DoctorsState.initial() {
    return DoctorsState(isLoading: false, doctors: [], error: null);
  }

  DoctorsState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? doctors,
    String? error,
  }) {
    return DoctorsState(
      isLoading: isLoading ?? this.isLoading,
      doctors: doctors ?? this.doctors,
      error: error,
    );
  }
}
