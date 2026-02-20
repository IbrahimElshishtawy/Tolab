class CommunityState {
  final bool isLoading;
  CommunityState({required this.isLoading});
  factory CommunityState.initial() => CommunityState(isLoading: false);
}
