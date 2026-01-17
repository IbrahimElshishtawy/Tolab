// ignore_for_file: file_names, strict_top_level_inference

class RouterViewModel {
  final bool isAuthenticated;
  final bool isLoading;
  final String? role;

  RouterViewModel({
    required this.isAuthenticated,
    required this.isLoading,
    required this.role,
  });

  factory RouterViewModel.fromStore(store) {
    final auth = store.state.authState;
    return RouterViewModel(
      isAuthenticated: auth.isAuthenticated,
      isLoading: auth.isLoading,
      role: auth.role,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RouterViewModel &&
          isAuthenticated == other.isAuthenticated &&
          isLoading == other.isLoading &&
          role == other.role;

  @override
  int get hashCode =>
      isAuthenticated.hashCode ^
      isLoading.hashCode ^
      role.hashCode;
}
