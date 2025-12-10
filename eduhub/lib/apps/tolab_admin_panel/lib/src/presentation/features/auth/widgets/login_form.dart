// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();

  bool _showPassword = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  // ---------------------------
  // LOAD SAVED CREDENTIALS
  // ---------------------------
  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString("saved_email");
    final pass = prefs.getString("saved_pass");

    if (email != null) _emailCtrl.text = email;
    if (pass != null) _passCtrl.text = pass;

    setState(() {
      _rememberMe = email != null;
    });
  }

  // ---------------------------
  // SAVE CREDENTIALS
  // ---------------------------
  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString("saved_email", _emailCtrl.text.trim());
      await prefs.setString("saved_pass", _passCtrl.text.trim());
    } else {
      await prefs.remove("saved_email");
      await prefs.remove("saved_pass");
    }
  }

  // ---------------------------
  // SUBMIT LOGIN
  // ---------------------------
  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    _saveCredentials();

    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();

    StoreProvider.of<AppState>(context).dispatch(LoginAction(email, pass));
  }

  InputDecoration _buildInputDecoration(
    String label,
    IconData icon, {
    bool isPassword = false,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.white.withOpacity(0.85),
        fontSize: 14,
      ),
      prefixIcon: Icon(icon, color: Colors.white),

      // Toggle password visibility
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                _showPassword ? Icons.visibility : Icons.visibility_off,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() => _showPassword = !_showPassword);
              },
            )
          : null,

      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white.withOpacity(0.80)),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white, width: 1.8),
        borderRadius: BorderRadius.circular(12),
      ),
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
              // ---------------------------------------
              // EMAIL FIELD
              // ---------------------------------------
              TextFormField(
                controller: _emailCtrl,
                focusNode: _emailFocus,
                cursorColor: Colors.white,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration(
                  "البريد الإلكتروني",
                  Icons.email_outlined,
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,

                onFieldSubmitted: (_) {
                  if (_emailCtrl.text.contains("@")) {
                    FocusScope.of(context).requestFocus(_passFocus);
                  }
                },

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

              // ---------------------------------------
              // PASSWORD FIELD
              // ---------------------------------------
              TextFormField(
                controller: _passCtrl,
                focusNode: _passFocus,
                cursorColor: Colors.white,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration(
                  "كلمة المرور",
                  Icons.lock_outline,
                  isPassword: true,
                ),
                obscureText: !_showPassword,
                textInputAction: TextInputAction.done,

                onFieldSubmitted: (_) => _onSubmit(),

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

              const SizedBox(height: 14),

              // ---------------------------------------
              // REMEMBER ME
              // ---------------------------------------
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    activeColor: Colors.white,
                    checkColor: Colors.black,
                    side: const BorderSide(color: Colors.white),
                    onChanged: (val) =>
                        setState(() => _rememberMe = val ?? false),
                  ),
                  const Text("تذكرني", style: TextStyle(color: Colors.white)),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ---------------------------------------
        // SUBMIT BUTTON
        // ---------------------------------------
        LoginSubmitButton(
          isLoading: widget.isLoading,
          onPressed: _onSubmit,
          isSuccess: false,
        ),
      ],
    );
  }
}
