import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'set_new_password_page.dart'; // الصفحة اللي هنعملها بعد التحقق

class VerifyCodePage extends StatefulWidget {
  const VerifyCodePage({super.key});

  @override
  State<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends State<VerifyCodePage> {
  final emailController = TextEditingController();
  final codeController = TextEditingController();
  String? message;
  bool isLoading = false;

  Future<void> verifyCode() async {
    final email = emailController.text.trim();
    final code = codeController.text.trim();

    setState(() {
      isLoading = true;
      message = null;
    });

    try {
      final doc = await FirebaseFirestore.instance
          .collection('reset_codes')
          .doc(email)
          .get();

      if (!doc.exists) {
        setState(() {
          message = '❌ لم يتم العثور على هذا البريد أو لم يُطلب رمز.';
        });
        return;
      }

      final data = doc.data()!;
      final savedCode = data['code'];
      final expiresAt = (data['expiresAt'] as Timestamp).toDate();

      if (DateTime.now().isAfter(expiresAt)) {
        setState(() {
          message = '⏰ انتهت صلاحية الكود. الرجاء طلب كود جديد.';
        });
        return;
      }

      if (code != savedCode) {
        setState(() {
          message = '❌ الكود الذي أدخلته غير صحيح.';
        });
        return;
      }

      // ✅ تم التحقق بنجاح
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SetNewPasswordPage(email: email)),
      );
    } catch (e) {
      setState(() {
        message = '❌ حدث خطأ أثناء التحقق: $e';
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
      appBar: AppBar(title: const Text('تأكيد الكود')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'من فضلك أدخل بريدك الإلكتروني والكود الذي وصلك على الإيميل.',
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
            ),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: 'رمز التحقق',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : verifyCode,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('تأكيد'),
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
