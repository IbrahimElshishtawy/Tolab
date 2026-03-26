import 'package:get/get.dart';

import '../../../config/admin_config.dart';
import '../../../core/network/api_exception_mapper.dart';
import '../../datasources/admin/admin_resource_remote_data_source.dart';
import '../../dto/pagination_query_dto.dart';
import '../../models/admin_models.dart';

class AdminResourceRepository<T extends AdminEntity> {
  AdminResourceRepository({
    required AdminResourceRemoteDataSource remoteDataSource,
    required this.endpoint,
    required this.parser,
    required this.seed,
  }) : _remoteDataSource = remoteDataSource;

  final AdminResourceRemoteDataSource _remoteDataSource;
  final String endpoint;
  final T Function(Map<String, dynamic> json) parser;
  final List<T> seed;
  List<T>? _cache;

  List<T> get _items => _cache ??= List<T>.from(seed);

  Future<PaginatedResponse<T>> fetch({
    int page = 1,
    int perPage = 10,
    String search = '',
  }) async {
    try {
      if (AdminConfig.useMockData) {
        final filtered = _items.where((item) {
          final query = search.trim().toLowerCase();
          if (query.isEmpty) return true;
          return item.primaryLabel.toLowerCase().contains(query) ||
              item.secondaryLabel.toLowerCase().contains(query) ||
              item.status.toLowerCase().contains(query);
        }).toList();
        final start = (page - 1) * perPage;
        final end = (start + perPage).clamp(0, filtered.length);
        return PaginatedResponse<T>(
          items: start >= filtered.length
              ? <T>[]
              : filtered.sublist(start, end),
          total: filtered.length,
          page: page,
          perPage: perPage,
        );
      }

      return await _remoteDataSource.getList<T>(
        endpoint: endpoint,
        query: PaginationQueryDto(page: page, perPage: perPage, search: search),
        parser: parser,
      );
    } catch (error) {
      throw ApiExceptionMapper.map(error);
    }
  }

  Future<T?> findById(String id) async {
    try {
      if (AdminConfig.useMockData) {
        return _items.firstWhereOrNull((item) => item.id == id);
      }
      return _remoteDataSource.getOne<T>(
        endpoint: '$endpoint/$id',
        parser: parser,
      );
    } catch (error) {
      throw ApiExceptionMapper.map(error);
    }
  }

  Future<T> save({
    required T entity,
    required Map<String, dynamic> body,
  }) async {
    try {
      if (AdminConfig.useMockData) {
        final index = _items.indexWhere((item) => item.id == entity.id);
        if (index >= 0) {
          _items[index] = entity;
        } else {
          _items.insert(0, entity);
        }
        return entity;
      }

      if (_items.any((item) => item.id == entity.id)) {
        return _remoteDataSource.update<T>(
          endpoint: '$endpoint/${entity.id}',
          body: body,
          parser: parser,
        );
      }
      return _remoteDataSource.create<T>(
        endpoint: endpoint,
        body: body,
        parser: parser,
      );
    } catch (error) {
      throw ApiExceptionMapper.map(error);
    }
  }

  Future<void> remove(String id) async {
    try {
      if (AdminConfig.useMockData) {
        _items.removeWhere((item) => item.id == id);
        return;
      }
      await _remoteDataSource.delete('$endpoint/$id');
    } catch (error) {
      throw ApiExceptionMapper.map(error);
    }
  }
}
