class CommunityState {
  final List<dynamic> posts;
  final bool isLoading;
  final String? error;

  CommunityState({
    required this.posts,
    required this.isLoading,
    this.error,
  });

  factory CommunityState.initial() => CommunityState(
    posts: [],
    isLoading: false,
  );

  CommunityState copyWith({
    List<dynamic>? posts,
    bool? isLoading,
    String? error,
  }) {
    return CommunityState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
