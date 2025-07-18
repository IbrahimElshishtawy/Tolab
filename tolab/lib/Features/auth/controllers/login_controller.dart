import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginController extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;
  bool showPassword = false;
  bool rememberMe = false;

  void togglePasswordVisibility() {
    showPassword = !showPassword;
    notifyListeners();
  }

  void toggleRememberMe(bool? value) {
    rememberMe = value ?? false;
    notifyListeners();
  }

  void setError(String message) {
    errorMessage = message;
    notifyListeners();
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> login(BuildContext context) async {
    setLoading(true);
    try {
      String emailInput = emailController.text.trim();
      final password = passwordController.text.trim();

      // إذا المستخدم لم يكتب @ نضيف دومين جامعة طنطا
      String email;
      if (!emailInput.contains('@')) {
        email = '$emailInput@ics.tanta.edu.eg';
      } else {
        email = emailInput;
      }

      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        setError(
          'فشل تسجيل الدخول: ${response.session?.accessToken ?? 'بيانات غير صحيحة'}',
        );
      } else {
        setError('');
        // يمكنك الانتقال إلى الصفحة التالية هنا
        // Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      setError('حدث خطأ أثناء تسجيل الدخول');
    } finally {
      setLoading(false);
    }
  }

  void clear() {
    emailController.clear();
    passwordController.clear();
    errorMessage = null;
    rememberMe = false;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
