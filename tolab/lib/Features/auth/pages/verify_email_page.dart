import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class ResetRequestPage extends StatefulWidget {
  const ResetRequestPage({super.key});

  @override
  State<ResetRequestPage> createState() => _ResetRequestPageState();
}

class _ResetRequestPageState extends State<ResetRequestPage> {
  final TextEditingController emailController = TextEditingController();
  String? message;
  bool isLoading = false;

  Future<void> sendVerificationCode(String email) async {
    setState(() {
      isLoading = true;
      message = null;
    });

    try {
      final code = _generateCode();
      final expiry = DateTime.now().add(const Duration(minutes: 5));

      // حفظ الكود في Firestore
      await FirebaseFirestore.instance.collection('reset_codes').doc(email).set(
        {'code': code, 'expiresAt': expiry},
      );

      // إرسال الكود عبر البريد
      await sendEmailToUser(email, code);

      setState(() {
        message = '✅ تم إرسال كود التحقق إلى بريدك الإلكتروني.';
      });
    } catch (e) {
      setState(() {
        message = '❌ حدث خطأ أثناء الإرسال: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _generateCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString(); // مثال: 6 أرقام
  }

  Future<void> sendEmailToUser(String email, String code) async {
    final smtpServer = gmail('your_email@gmail.com', 'your_app_password');

    final message = Message()
      ..from = const Address('your_email@gmail.com', 'ToLab App')
      ..recipients.add(email)
      ..subject = 'رمز التحقق لإعادة تعيين كلمة المرور'
      ..text = 'رمز التحقق الخاص بك هو: $code\n\nالكود صالح لمدة 5 دقائق.';

    await send(message, smtpServer);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إعادة تعيين كلمة المرور')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'من فضلك أدخل بريدك الإلكتروني وسنرسل لك رمز تحقق (OTP) لتغيير كلمة المرور.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'البريد الإلكتروني',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: isLoading
                  ? null
                  : () => sendVerificationCode(emailController.text.trim()),
              icon: const Icon(Icons.send),
              label: isLoading
                  ? const Text('جارٍ الإرسال...')
                  : const Text('إرسال الكود'),
            ),
            if (message != null) ...[
              const SizedBox(height: 20),
              Text(
                message!,
                style: TextStyle(
                  color: message!.contains('✅') ? Colors.green : Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
