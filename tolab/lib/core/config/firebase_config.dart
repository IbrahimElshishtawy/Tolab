// lib/core/config/firebase_config.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class FirebaseInitializer {
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  }
}
