class PaginationQueryDto {
  const PaginationQueryDto({
    this.page = 1,
    this.perPage = 10,
    this.search = '',
  });

  final int page;
  final int perPage;
  final String search;

  Map<String, dynamic> toJson() => {
    'page': page,
    'per_page': perPage,
    if (search.isNotEmpty) 'search': search,
  };
}
