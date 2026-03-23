class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
  });

  final List<T> items;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;

  bool get hasMore => currentPage < lastPage;

  factory PaginatedResponse.fromLaravel(
    dynamic raw,
    T Function(Map<String, dynamic> json) mapper,
  ) {
    if (raw is Map<String, dynamic>) {
      final list = (raw['data'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(mapper)
          .toList();
      final meta = raw['meta'] as Map<String, dynamic>? ?? raw;
      return PaginatedResponse(
        items: list,
        currentPage: (meta['current_page'] as num?)?.toInt() ?? 1,
        lastPage: (meta['last_page'] as num?)?.toInt() ?? 1,
        total: (meta['total'] as num?)?.toInt() ?? list.length,
        perPage: (meta['per_page'] as num?)?.toInt() ?? list.length,
      );
    }

    final list = (raw as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(mapper)
        .toList();
    return PaginatedResponse(
      items: list,
      currentPage: 1,
      lastPage: 1,
      total: list.length,
      perPage: list.length,
    );
  }
}
