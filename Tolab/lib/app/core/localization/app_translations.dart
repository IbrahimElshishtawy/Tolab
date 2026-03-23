import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppTranslations extends Translations {
  static const fallbackLocale = Locale('en');

  @override
  Map<String, Map<String, String>> get keys => {
    'en': {
      'app_name': 'Tolab',
      'welcome_title': 'Your university day, beautifully organized.',
      'welcome_body':
          'Courses, grades, schedule, groups, and notifications in one premium workspace.',
      'continue': 'Continue',
      'skip': 'Skip',
      'get_started': 'Get started',
      'login': 'Login',
      'email': 'Email address',
      'password': 'Password',
      'forgot_password': 'Forgot password?',
      'dashboard': 'Dashboard',
      'courses': 'Courses',
      'schedule': 'Schedule',
      'notifications': 'Notifications',
      'profile': 'Profile',
      'settings': 'Settings',
      'logout': 'Logout',
      'retry': 'Retry',
      'no_internet': 'No internet connection',
      'search': 'Search',
    },
    'ar': {
      'app_name': 'طلاب',
      'welcome_title': 'يومك الجامعي منظم بشكل أنيق.',
      'welcome_body':
          'المقررات والدرجات والجدول والمجموعات والتنبيهات في مساحة واحدة.',
      'continue': 'متابعة',
      'skip': 'تخطي',
      'get_started': 'ابدأ الآن',
      'login': 'تسجيل الدخول',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'forgot_password': 'نسيت كلمة المرور؟',
      'dashboard': 'الرئيسية',
      'courses': 'المقررات',
      'schedule': 'الجدول',
      'notifications': 'التنبيهات',
      'profile': 'الملف الشخصي',
      'settings': 'الإعدادات',
      'logout': 'تسجيل الخروج',
      'retry': 'إعادة المحاولة',
      'no_internet': 'لا يوجد اتصال بالإنترنت',
      'search': 'بحث',
    },
  };
}
