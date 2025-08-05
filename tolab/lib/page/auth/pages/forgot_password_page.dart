import 'package:flutter/material.dart';
import 'package:tolab/core/config/firebase_check.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPage();
}

class _ForgotPasswordPage extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  bool isEmailValidFormat = false;
  bool? isEmailExists;
  String? message;

  void checkEmail(String email) async {
    setState(() {
      isEmailValidFormat = RegExp(
        r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
      ).hasMatch(email);
      isEmailExists = null;
      message = null;
    });

    if (isEmailValidFormat) {
      final exists = await FirebaseCheck.checkEmailExists(email);
      setState(() {
        isEmailExists = exists;
        message = exists ? "✅ البريد الإلكتروني موجود" : "❌ البريد غير موجود";
      });
    }
  }

  Future<void> submit() async {
    final email = emailController.text.trim();

    if (!isEmailValidFormat) {
      setState(() => message = '❌ صيغة البريد غير صحيحة.');
      return;
    }

    if (isEmailExists != true) {
      setState(() => message = '❌ هذا البريد غير مسجل.');
      return;
    }

    final result = await FirebaseCheck.sendResetPassword(email);
    setState(() {
      message = result ?? '✅ تم إرسال رابط الاستعادة إلى بريدك.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إعادة تعيين كلمة المرور')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              onChanged: checkEmail,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'البريد الإلكتروني',
                suffixIcon: isEmailExists == null
                    ? null
                    : isEmailExists == true
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.error, color: Colors.red),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: isEmailExists == null
                        ? Colors.grey
                        : isEmailExists == true
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: submit,
              icon: const Icon(Icons.send),
              label: const Text('إرسال رابط الاستعادة'),
            ),
            const SizedBox(height: 20),
            if (message != null)
              Text(
                message!,
                style: TextStyle(
                  color: message!.startsWith('✅') ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
