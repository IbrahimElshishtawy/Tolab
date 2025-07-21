// lib/auth/pages/verify_code_page.dart

import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class VerifyCodePage extends StatefulWidget {
  const VerifyCodePage({super.key});

  @override
  State<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends State<VerifyCodePage> {
  String otpCode = '';
  String? message;

  void verifyCode() {
    if (otpCode.length != 6) {
      setState(() {
        message = '❌ أدخل رمز تحقق مكون من 6 أرقام.';
      });
      return;
    }

    // هنا يفترض أن يتم التحقق من الكود مع السيرفر
    Navigator.pushNamed(context, '/reset_password');
  }

  void resendCode() {
    // إرسال الكود مرة أخرى
    setState(() {
      message = '✅ تم إعادة إرسال الكود إلى بريدك الإلكتروني.';
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('رمز التحقق')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'أدخل رمز التحقق المكون من 6 أرقام الذي تم إرساله إلى بريدك الإلكتروني.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              PinCodeTextField(
                appContext: context,
                length: 6,
                keyboardType: TextInputType.number,
                onChanged: (value) => otpCode = value,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(10),
                  fieldHeight: 50,
                  fieldWidth: 40,
                  activeColor: Colors.blue,
                  selectedColor: Colors.orange,
                  inactiveColor: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: verifyCode, child: const Text('تأكيد')),
              const SizedBox(height: 10),
              TextButton(
                onPressed: resendCode,
                child: const Text('إعادة إرسال الكود'),
              ),
              if (message != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    message!,
                    style: TextStyle(
                      color: message!.contains('❌') ? Colors.red : Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
