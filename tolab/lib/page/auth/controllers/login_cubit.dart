import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:tolab/core/config/User_Provider.dart';
import 'package:tolab/page/auth/controllers/login_state.dart';
import 'package:tolab/page/auth/controllers/src/google_sign_in_service.dart';

class LoginCubit extends Cubit<LoginState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool rememberMe = false;
  bool isPasswordVisible = false;
  User? user;

  LoginCubit() : super(LoginInitial()) {
    loadSavedCredentials();
  }

  /// Toggle remember me checkbox
  void toggleRememberMe(bool value) {
    rememberMe = value;
    emit(LoginRememberMeChanged(value));
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    emit(LoginPasswordVisibilityToggled(isPasswordVisible));
  }

  /// Load saved email/password from local storage
  Future<void> loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('saved_email') ?? '';
    final password = prefs.getString('saved_password') ?? '';
    final remember = prefs.getBool('remember_me') ?? false;

    emailController.text = email;
    passwordController.text = password;
    rememberMe = remember;

    emit(
      LoginLoadedSavedCredentials(
        email: email,
        password: password,
        rememberMe: remember,
      ),
    );
  }

  /// Handle login with email/password
  Future<void> login(BuildContext context) async {
    emit(LoginLoading());
    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      await _auth.signInWithEmailAndPassword(email: email, password: password);

      final currentUser = _auth.currentUser;
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.setUser(currentUser);

      final prefs = await SharedPreferences.getInstance();
      if (rememberMe) {
        await prefs.setString('saved_email', email);
        await prefs.setString('saved_password', password);
        await prefs.setBool('remember_me', true);
        await prefs.setBool('isLoggedIn', true);
      } else {
        await prefs.remove('saved_email');
        await prefs.remove('saved_password');
        await prefs.setBool('remember_me', false);
      }

      emit(LoginSuccess());
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      String message = 'حدث خطأ أثناء تسجيل الدخول.';
      if (e.code == 'user-not-found') {
        message = 'هذا البريد غير مسجل.';
      } else if (e.code == 'wrong-password') {
        message = 'كلمة المرور غير صحيحة.';
      } else if (e.code == 'invalid-credential') {
        message = 'البيانات غير صحيحة أو انتهت صلاحيتها.';
      }
      emit(LoginFailure(message));
    }
  }

  /// Google Sign In logic
  Future<void> handleGoogleSignIn(BuildContext context) async {
    try {
      final userCredential = await GoogleSignInService.signInWithGoogle();
      if (userCredential == null) return;

      user = userCredential.user;
      if (user != null) {
        await _createSelfChatIfNotExists(user!.uid);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_email', user!.email ?? '');
        await prefs.setBool('remember_me', true);

        emit(LoginGoogleSuccess(user!));
        Navigator.pushReplacementNamed(context, '/choose-role');
      }
    } catch (e) {
      emit(LoginFailure('فشل تسجيل الدخول بواسطة Google'));
    }
  }

  /// إنشاء دردشة ذاتية إذا لم تكن موجودة
  Future<void> _createSelfChatIfNotExists(String userId) async {
    final chatRef = FirebaseFirestore.instance
        .collection('chats')
        .where('members', isEqualTo: [userId]);

    final snapshot = await chatRef.get();

    if (snapshot.docs.isEmpty) {
      await FirebaseFirestore.instance.collection('chats').add({
        'members': [userId],
        'createdAt': FieldValue.serverTimestamp(),
        'isSelfChat': true,
      });
    }
  }

  /// Logout and clear preferences
  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }
}
