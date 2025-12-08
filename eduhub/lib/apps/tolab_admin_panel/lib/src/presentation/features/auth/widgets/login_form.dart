import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../../../../state/app_state.dart';
import '../../../../state/auth/auth_actions.dart';
import 'login_submit_button.dart';

class LoginForm extends StatefulWidget {
  final bool isLoading;

  const LoginForm({super.key, required this.isLoading});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();

    StoreProvider.of<AppState>(context).dispatch(LoginAction(email, pass));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: "البريد الإلكتروني",
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "ادخل البريد الإلكتروني";
                  }
                  if (!value.contains("@")) {
                    return "بريد إلكتروني غير صالح";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passCtrl,
                decoration: const InputDecoration(
                  labelText: "كلمة المرور",
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "ادخل كلمة المرور";
                  }
                  if (value.length < 6) {
                    return "كلمة المرور يجب أن تكون 6 أحرف على الأقل";
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        LoginSubmitButton(isLoading: widget.isLoading, onPressed: _onSubmit),
      ],
    );
  }
}
