// ignore_for_file: file_names

import 'package:eduhub/fake_data/data.dart';

class ApiServiceAuth {
  Future<String> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 1000)); // simulate server
    final admin = admins.firstWhere(
      (a) => a["email"] == email && a["password"] == password,
      orElse: () => {},
    );

    if (admin.isNotEmpty) {
      return "TOKEN_${admin['email']}";
    }

    throw Exception("Invalid credentials");
  }
}
