// lib/core/services/file_service.dart

// ignore_for_file: unnecessary_null_comparison

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FileService {
  static final SupabaseClient _client = Supabase.instance.client;

  /// رفع ملف إلى التخزين
  static Future<String?> uploadFile(String bucket, String path) async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;

      final response = await _client.storage
          .from(bucket)
          .upload(
            '$path/$fileName',
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      if (response != null) {
        return _client.storage.from(bucket).getPublicUrl('$path/$fileName');
      }
    }
    return null;
  }

  /// جلب FCM Token
  static Future<String?> getFcmToken() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (kDebugMode) {
        print('✅ FCM Token: $fcmToken');
      }
      return fcmToken;
    } catch (e) {
      if (kDebugMode) {
        print('❌ خطأ في جلب FCM Token: $e');
      }
      return null;
    }
  }

  /// حذف ملف من التخزين
  static Future<bool> deleteFile(String bucket, String filePath) async {
    final result = await _client.storage.from(bucket).remove([filePath]);
    return result.isEmpty;
  }

  /// جلب رابط ملف عام
  static String getPublicUrl(String bucket, String path) {
    return _client.storage.from(bucket).getPublicUrl(path);
  }
}
