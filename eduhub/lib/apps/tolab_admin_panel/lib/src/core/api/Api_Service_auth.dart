// ignore_for_file: file_names

import 'package:eduhub/fake_data/data.dart';

class ApiServiceAuth {
  Future<String> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800)); // simulate server

    // البحث عن المستخدم داخل fake_data
    final admin = admins.firstWhere(
      (a) => a["email"] == email && a["password"] == password,
      orElse: () => {},
    );

    if (admin.isNotEmpty) {
      // رجّع توكن وهمي (في الحقيقة يمكنك إرجاع user object وليس token فقط)
      return "TOKEN_${admin['email']}";
    }

    throw Exception("Invalid credentials");
  }
}
