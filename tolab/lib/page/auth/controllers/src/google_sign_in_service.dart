// ignore_for_file: unnecessary_null_comparison, unused_element, await_only_futures

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

const String _webClientId =
    '168050637950-la7d6jh8f4ahh90f6pulndhkbi1bmi95.apps.googleusercontent.com';

class GoogleSignInService {
  static final _google = GoogleSignIn.instance;
  static final _auth = FirebaseAuth.instance;
  static bool _inited = false;

  BuildContext get context =>
      throw UnimplementedError('context is not implemented');

  static Future<void> init() async {
    if (!_inited) {
      await _google.initialize(serverClientId: _webClientId);
      _inited = true;
    }
  }

  static Future<UserCredential?> signInWithGoogle() async {
    await init();
    try {
      final acct = await _google.authenticate();
      if (acct == null) return null;

      final auth = await acct.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: auth.idToken,
        accessToken: auth.idToken,
        // accessToken اختياري,
      );
      return await _auth.signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
  }

  Future<void> createSelfChatIfNotExists(String userId) async {
    final chatRef = FirebaseFirestore.instance
        .collection('chats')
        .where('members', isEqualTo: [userId])
        .where('type', isEqualTo: 'self');

    final snapshot = await chatRef.get();

    if (snapshot.docs.isEmpty) {
      await FirebaseFirestore.instance.collection('chats').add({
        'members': [userId],
        'type': 'self',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  static Future<void> signOut() async {
    await _google.signOut();
    await _auth.signOut();
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      final userCredential = await GoogleSignInService.signInWithGoogle();
      if (userCredential == null) return;

      final user = userCredential.user;

      if (user != null) {
        final chatRef = FirebaseFirestore.instance
            .collection('chats')
            .doc('self_${user.uid}');

        final doc = await chatRef.get();
        if (!doc.exists) {
          await chatRef.set({
            'members': [user.uid],
            'type': 'self',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      if (kDebugMode) print('فشل تسجيل الدخول: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل تسجيل الدخول بواسطة Google')),
        );
      }
    }
  }
}
