import 'package:flutter/material.dart';

class AppLocalization {
  final Locale locale;
  AppLocalization(this.locale);

  static AppLocalization of(BuildContext context) {
    return Localizations.of<AppLocalization>(context, AppLocalization)!;
  }

  static const _localizedValues = {
    'en': {
      'login_title': 'Educator Login',
      'email': 'University Email',
      'password': 'Password',
      'login_button': 'Login',
      // Add more here
    },
    'ar': {
      'login_title': 'دخول المحاضر',
      'email': 'البريد الإلكتروني الجامعي',
      'password': 'كلمة المرور',
      'login_button': 'تسجيل الدخول',
      // Add more here
    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}
