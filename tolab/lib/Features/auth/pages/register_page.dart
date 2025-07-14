// ✅ RegisterPage.dart (واجهة التسجيل)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tolab/Features/auth/controllers/register_controller.dart';
import 'package:tolab/Features/auth/widgets/register_form.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterController(),
      child: Consumer<RegisterController>(
        builder: (context, controller, _) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: const Text(
                "إنشاء حساب",
                style: TextStyle(color: Colors.black),
              ),
              iconTheme: const IconThemeData(color: Colors.black),
              elevation: 1,
              centerTitle: true,
            ),
            body: const SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: RegisterForm(),
            ),
          );
        },
      ),
    );
  }
}
