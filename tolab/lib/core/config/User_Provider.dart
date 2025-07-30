// lib/core/providers/user_provider.dart

// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  void setUser(User? user) {
    _user = user;
    notifyListeners();
  }

  String get userName => _user?.displayName ?? 'مستخدم';

  get userData => null;
}
