import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tolab/core/services/auth_service.dart';
import 'package:tolab/core/services/user_service.dart';

class AuthController with ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final nationalIdController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;
  bool isPasswordVisible = false;

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void clearFields() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    nameController.clear();
    ageController.clear();
    nationalIdController.clear();
  }

  /// ✅ عملية تسجيل الدخول
  Future<bool> login() async {
    setLoading(true);
    try {
      final response = await AuthService.signIn(
        email: emailController.text,
        password: passwordController.text,
      );

      if (response?.user != null) {
        if (!AuthService.isEmailVerified()) {
          errorMessage = "يجب تأكيد البريد الإلكتروني أولاً.";
          setLoading(false);
          return false;
        }
        return true;
      } else {
        errorMessage = "فشل تسجيل الدخول. تحقق من البيانات.";
        return false;
      }
    } on AuthException catch (e) {
      errorMessage = e.message;
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// ✅ عملية إنشاء حساب جديد
  Future<bool> register() async {
    setLoading(true);
    try {
      if (passwordController.text != confirmPasswordController.text) {
        errorMessage = "كلمة المرور غير متطابقة";
        setLoading(false);
        return false;
      }

      final response = await AuthService.signUp(
        email: emailController.text,
        password: passwordController.text,
      );

      if (response?.user != null) {
        // حفظ بيانات المستخدم في قاعدة البيانات
        await UserService.saveUserProfile(
          uid: response!.user!.id,
          data: {
            'email': emailController.text,
            'name': nameController.text,
            'age': ageController.text,
            'national_id': nationalIdController.text,
          },
        );
        return true;
      } else {
        errorMessage = "فشل إنشاء الحساب.";
        return false;
      }
    } on AuthException catch (e) {
      errorMessage = e.message;
      return false;
    } finally {
      setLoading(false);
    }
  }
}
