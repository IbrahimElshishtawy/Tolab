import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  String _role = 'student';

  User? get user => _user;
  String get role => _role;

  Future<void> setUser(User? user) async {
    _user = user;
    notifyListeners();
    if (_user != null) {
      await _loadRole();
    }
  }

  Future<void> _loadRole() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .get();
      final data = doc.data();
      _role = (data != null && data['role'] is String)
          ? data['role'] as String
          : 'student';
    } catch (e) {
      if (kDebugMode) print('Error loading role: $e');
    }
    notifyListeners();
  }

  void setRole(String newRole) {
    _role = newRole;
    notifyListeners();
  }
}
