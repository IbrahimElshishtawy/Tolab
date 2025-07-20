import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SetNewPasswordPage extends StatefulWidget {
  const SetNewPasswordPage({super.key, required String email});

  @override
  State<SetNewPasswordPage> createState() => _SetNewPasswordPageState();
}

class _SetNewPasswordPageState extends State<SetNewPasswordPage> {
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;
  String? error;

  Future<void> updatePassword() async {
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (newPassword != confirmPassword) {
      setState(() {
        error = 'كلمتا المرور غير متطابقتين';
      });
      return;
    }

    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
        await FirebaseAuth.instance
            .signOut(); // تسجيل الخروج بعد تغيير الباسورد

        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      } else {
        setState(() {
          error = 'لم يتم العثور على المستخدم';
        });
      }
    } catch (e) {
      setState(() {
        error = 'حدث خطأ: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('كلمة مرور جديدة')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور الجديدة',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(labelText: 'تأكيد كلمة المرور'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: isLoading ? null : updatePassword,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('تحديث كلمة المرور'),
            ),
          ],
        ),
      ),
    );
  }
}
