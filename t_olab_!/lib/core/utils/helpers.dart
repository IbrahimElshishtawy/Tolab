// lib/core/utils/helpers.dart

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Helpers {
  /// ✅ عرض Toast برسالة
  static void showToast(
    String message, {
    Color bgColor = Colors.black,
    Color textColor = Colors.white,
  }) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: bgColor,
      textColor: textColor,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  /// ✅ عرض حوار تأكيد
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'نعم',
    String cancelText = 'إلغاء',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, textAlign: TextAlign.right),
        content: Text(content, textAlign: TextAlign.right),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// ✅ إغلاق لوحة المفاتيح
  static void closeKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// ✅ تحويل Timestamp إلى وقت مقروء
  static String formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  /// ✅ اختصار النص الطويل
  static String truncateText(String text, {int maxLength = 50}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
