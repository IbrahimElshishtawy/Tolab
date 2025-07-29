import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationService {
  static const String serverKey = 'YOUR_SERVER_KEY'; // حط مفتاح FCM هنا

  static Future<void> sendNotificationToUser(
    String receiverId,
    String message,
  ) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(receiverId)
          .get();

      final token = doc['fcmToken'];
      if (token == null) return;

      final body = {
        "to": token,
        "notification": {
          "title": "رسالة جديدة",
          "body": message,
          "sound": "default",
        },
        "data": {"click_action": "FLUTTER_NOTIFICATION_CLICK"},
      };

      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "key=$serverKey",
        },
        body: jsonEncode(body),
      );
    } catch (e) {
      print('Failed to send notification: $e');
    }
  }
}
