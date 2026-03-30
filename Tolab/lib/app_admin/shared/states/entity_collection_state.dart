import '../enums/load_status.dart';

class EntityCollectionState<T> {
  const EntityCollectionState({
    this.items = const [],
    this.status = LoadStatus.initial,
    this.errorMessage,
    this.query = '',
  });

  final List<T> items;
  final LoadStatus status;
  final String? errorMessage;
  final String query;

  EntityCollectionState<T> copyWith({
    List<T>? items,
    LoadStatus? status,
    String? errorMessage,
    String? query,
    bool clearError = false,
  }) {
    return EntityCollectionState<T>(
      items: items ?? this.items,
      status: status ?? this.status,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      query: query ?? this.query,
    );
  }
}
