// lib/core/services/user_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  static final SupabaseClient _client = Supabase.instance.client;
  static const String tableName = 'user_data';

  /// ✅ إضافة مستخدم جديد ببيانات إضافية
  static Future<void> addUserData({
    required String uid,
    required String fullName,
    required int age,
    required String nationalId,
    required String universityEmail,
  }) async {
    await _client.from(tableName).insert({
      'id': uid,
      'full_name': fullName,
      'age': age,
      'national_id': nationalId,
      'university_email': universityEmail,
    });
  }

  /// ✅ تحديث بيانات المستخدم
  static Future<void> updateUserData({
    required String uid,
    String? fullName,
    int? age,
    String? nationalId,
    String? universityEmail,
  }) async {
    final Map<String, dynamic> updates = {};
    if (fullName != null) updates['full_name'] = fullName;
    if (age != null) updates['age'] = age;
    if (nationalId != null) updates['national_id'] = nationalId;
    if (universityEmail != null) updates['university_email'] = universityEmail;

    await _client.from(tableName).update(updates).eq('id', uid);
  }

  /// ✅ جلب بيانات المستخدم
  static Future<Map<String, dynamic>?> getUserData(String uid) async {
    final response = await _client
        .from(tableName)
        .select()
        .eq('id', uid)
        .maybeSingle();

    return response;
  }

  /// ✅ حذف بيانات المستخدم
  static Future<void> deleteUser(String uid) async {
    await _client.from(tableName).delete().eq('id', uid);
  }

  /// ✅ حفظ بيانات المستخدم (إنشاء أو تحديث)
  static Future<void> saveUserProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    await _client.from(tableName).upsert({
      'id': uid, // تأكد أن هذا العمود هو Primary Key في Supabase
      ...data,
    });
  }

  /// ✅ جلب ملف المستخدم (نسخة مضمونة single)
  static Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final response = await _client
        .from(tableName)
        .select()
        .eq('id', uid)
        .single();
    return response;
  }
}
