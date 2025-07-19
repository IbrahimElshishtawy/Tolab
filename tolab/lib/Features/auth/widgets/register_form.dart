import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/register_controller.dart';
import 'register_fields.dart';

class RegisterForm extends StatelessWidget {
  const RegisterForm({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterController(),
      child: Scaffold(
        body: const Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(child: RegisterFields()),
        ),
      ),
    );
  }
}
