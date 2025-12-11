class AssistantsState {
  final bool isLoading;
  final List<Map<String, dynamic>> assistants;
  final String? error;

  AssistantsState({
    required this.isLoading,
    required this.assistants,
    this.error,
  });

  factory AssistantsState.initial() {
    return AssistantsState(isLoading: false, assistants: [], error: null);
  }

  AssistantsState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? assistants,
    String? error,
  }) {
    return AssistantsState(
      isLoading: isLoading ?? this.isLoading,
      assistants: assistants ?? this.assistants,
      error: error,
    );
  }
}
