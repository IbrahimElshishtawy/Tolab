class PaginationQueryDto {
  const PaginationQueryDto({this.page = 1, this.perPage = 12, this.search});

  final int page;
  final int perPage;
  final String? search;

  Map<String, dynamic> toQuery() => {
    'page': page,
    'per_page': perPage,
    if (search?.isNotEmpty == true) 'search': search,
  };
}
