// lib/core/services/supabase_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  /// تنفيذ استعلام SQL مخصص
  static Future<PostgrestList> executeQuery(
    String table, {
    Map<String, dynamic>? filters,
  }) async {
    var query = client.from(table).select();
    if (filters != null) {
      filters.forEach((key, value) {
        query = query.eq(key, value);
      });
    }
    return await query;
  }

  /// إدخال بيانات جديدة
  static Future<PostgrestResponse> insert(
    String table,
    Map<String, dynamic> data,
  ) async {
    return await client.from(table).insert(data);
  }

  /// تحديث بيانات
  static Future<PostgrestResponse> update(
    String table,
    Map<String, dynamic> data,
    String key,
    dynamic value,
  ) async {
    return await client.from(table).update(data).eq(key, value);
  }

  /// حذف بيانات
  static Future<PostgrestResponse> delete(
    String table,
    String key,
    dynamic value,
  ) async {
    return await client.from(table).delete().eq(key, value);
  }
}
