// lib/core/models/auth_state_model.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthStateModel extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  User? _user;
  User? get user => _user;

  bool get isLoggedIn => _user != null;
  bool get isEmailVerified => _user?.emailConfirmedAt != null;

  AuthStateModel() {
    _user = _client.auth.currentUser;
    _client.auth.onAuthStateChange.listen((data) {
      _user = data.session?.user;
      notifyListeners();
    });
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    final response = await _client.auth.getUser();
    _user = response.user;
    notifyListeners();
  }

  void logout() async {
    await _client.auth.signOut();
    _user = null;
    notifyListeners();
  }
}
