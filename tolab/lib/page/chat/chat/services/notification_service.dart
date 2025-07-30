import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationService {
  static const String serverUrl =
      'http://YOUR_SERVER_IP:3000/send-notification';
  // ❗ غيّر YOUR_SERVER_IP إلى IP الحقيقي لجهازك الذي يشغل السيرفر (مثلاً: 192.168.1.5)

  static Future<void> sendNotificationToUser({
    required String receiverId,
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(serverUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"receiverId": receiverId, "message": message}),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('✅ Notification sent successfully');
        }
      } else {
        if (kDebugMode) {
          print('❌ Failed to send notification: ${response.body}');
        }
      }
    } catch (e) {
      print('❌ Exception while sending notification: $e');
    }
  }
}
