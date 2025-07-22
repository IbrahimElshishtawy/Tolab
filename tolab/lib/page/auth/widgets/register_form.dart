import 'package:flutter/material.dart';
import 'register_fields.dart';

class RegisterForm extends StatelessWidget {
  const RegisterForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(children: const [RegisterFields()]),
    );
  }
}
