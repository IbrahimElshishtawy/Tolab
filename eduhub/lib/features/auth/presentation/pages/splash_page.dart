// features/auth/presentation/widgets/login_form.dart

import 'package:flutter/material.dart';

typedef LoginSubmitCallback =
    void Function(String email, String password, bool rememberMe);

class LoginForm extends StatefulWidget {
  final bool isLoading;
  final LoginSubmitCallback onSubmit;

  const LoginForm({super.key, required this.isLoading, required this.onSubmit});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (widget.isLoading) return;

    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _rememberMe,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.all(Radius.circular(16));

    return Form(
      key: _formKey,
      child: Column(
        children: [
          // حقل البريد الإلكتروني
          Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: InputBorder.none,
                labelText: 'البريد الإلكتروني',
                hintText: 'Mail@mail.com',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'من فضلك أدخل البريد الإلكتروني';
                }
                // validation بسيط
                if (!value.contains('@')) {
                  return 'البريد الإلكتروني غير صالح';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),

          // حقل كلمة المرور
          Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleSubmit(),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: InputBorder.none,
                labelText: 'كلمة المرور',
                hintText: 'أدخل كلمة المرور',
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'من فضلك أدخل كلمة المرور';
                }
                if (value.length < 4) {
                  return 'كلمة المرور قصيرة جداً';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 12),

          // نسيت كلمة المرور + ذكرني
          Row(
            children: [
              // نسيت كلمة المرور
              TextButton(
                onPressed: () {
                  // TODO: بعدين اربطها بشاشة reset password
                },
                child: const Text(
                  'نسيت كلمة المرور',
                  style: TextStyle(
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const Spacer(),

              // ذكرني + تشيك بوكس
              Row(
                children: [
                  const Text('ذكرني', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  SizedBox(
                    height: 18,
                    width: 18,
                    child: Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // زر تسجيل الدخول
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: widget.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'تسجيل الدخول',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
