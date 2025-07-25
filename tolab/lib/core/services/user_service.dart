// lib/core/services/user_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  static final SupabaseClient _client = Supabase.instance.client;
  static const String tableName = 'user_data';

  /// إضافة مستخدم جديد ببيانات كاملة
  static Future<void> addUserData({
    required String uid,
    required String fullName,
    required int age,
    required String nationalId,
    required String universityEmail,
    required String role, // جديد
    bool canPost = false, // جديد - افتراضي false
  }) async {
    await _client.from(tableName).insert({
      'id': uid,
      'full_name': fullName,
      'age': age,
      'national_id': nationalId,
      'university_email': universityEmail,
      'role': role,
      'can_post': canPost,
    });
  }

  /// تحديث بيانات المستخدم (بشكل مرن)
  static Future<void> updateUserData({
    required String uid,
    String? fullName,
    int? age,
    String? nationalId,
    String? universityEmail,
    String? role, // جديد
    bool? canPost, // جديد
  }) async {
    final Map<String, dynamic> updates = {};
    if (fullName != null) updates['full_name'] = fullName;
    if (age != null) updates['age'] = age;
    if (nationalId != null) updates['national_id'] = nationalId;
    if (universityEmail != null) updates['university_email'] = universityEmail;
    if (role != null) updates['role'] = role;
    if (canPost != null) updates['can_post'] = canPost;

    await _client.from(tableName).update(updates).eq('id', uid);
  }

  /// جلب بيانات مستخدم (nullable)
  static Future<Map<String, dynamic>?> getUserData(String uid) async {
    final response = await _client
        .from(tableName)
        .select()
        .eq('id', uid)
        .maybeSingle();

    return response;
  }

  /// جلب بيانات المستخدم (مع تأكيد وجود)
  static Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final response = await _client
        .from(tableName)
        .select()
        .eq('id', uid)
        .single();

    return response;
  }

  /// حذف مستخدم
  static Future<void> deleteUser(String uid) async {
    await _client.from(tableName).delete().eq('id', uid);
  }

  /// حفظ أو تحديث ملف المستخدم
  static Future<void> saveUserProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    await _client.from(tableName).upsert({'id': uid, ...data});
  }
}
