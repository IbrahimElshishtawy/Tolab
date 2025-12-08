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

  InputDecoration _whiteInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.white.withOpacity(0.85),
        fontSize: 14,
      ),
      prefixIcon: Icon(icon, color: Colors.white),

      // white borders
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.80),
          width: 1.3,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white, width: 1.8),
        borderRadius: BorderRadius.circular(14),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
        borderRadius: BorderRadius.circular(14),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.8),
        borderRadius: BorderRadius.circular(14),
      ),

      // padding
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    );
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
                cursorColor: Colors.white,
                style: const TextStyle(color: Colors.white),
                decoration: _whiteInputDecoration(
                  "البريد الإلكتروني",
                  Icons.email_outlined,
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
                cursorColor: Colors.white,
                style: const TextStyle(color: Colors.white),
                decoration: _whiteInputDecoration(
                  "كلمة المرور",
                  Icons.lock_outline,
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
