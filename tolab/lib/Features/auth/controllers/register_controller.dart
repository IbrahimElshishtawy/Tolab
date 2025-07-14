// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tolab/core/services/auth_service.dart';
import 'package:tolab/core/services/user_service.dart';
import 'package:tolab/core/utils/national_id_parser.dart';

class RegisterController extends ChangeNotifier {
  // Controllers
  final fullNameController = TextEditingController();
  final nationalIdController = TextEditingController();
  final universityEmailController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // متغيرات للدروب داون
  String? selectedDepartment;
  String? selectedStudyYear;
  String? selectedUserType = 'طالب';

  DateTime? birthDate;
  String? gender;
  String? city;

  String? errorMessage;
  bool isLoading = false;

  // متغيرات حالة اظهار / اخفاء كلمة المرور
  bool showPassword = false;
  bool showConfirmPassword = false;

  void setDepartment(String? dep) {
    selectedDepartment = dep;
    print('🔹 القسم تم اختياره: $dep');
    notifyListeners();
  }

  void setStudyYear(String? year) {
    selectedStudyYear = year;
    print('🔹 السنة الدراسية تم اختيارها: $year');
    notifyListeners();
  }

  void setUserType(String? type) {
    selectedUserType = type;
    print('🔹 نوع المستخدم تم تغييره إلى: $type');
    notifyListeners();
  }

  bool get isPasswordMatched =>
      passwordController.text == confirmPasswordController.text;

  void extractNationalIdData(String value) {
    if (value.length != 14) {
      print('⚠️ الرقم القومي غير مكتمل');
      return;
    }

    final date = NationalIdParser.extractBirthDate(value);
    final gend = NationalIdParser.extractGender(value);
    final cit = NationalIdParser.extractCity(value);

    print(
      '🔍 استخراج بيانات الرقم القومي: تاريخ الميلاد=$date, النوع=$gend, المحافظة=$cit',
    );

    if (date != null && gend != null && cit != null) {
      birthDate = date;
      gender = gend;
      city = cit;
      notifyListeners();
    } else {
      print('⚠️ فشل في استخراج بيانات الرقم القومي');
    }
  }

  String get birthDateString =>
      "${birthDate!.year}-${birthDate!.month.toString().padLeft(2, '0')}-${birthDate!.day.toString().padLeft(2, '0')}";

  Future<bool> register() async {
    print('🚀 بدء عملية التسجيل');

    final name = fullNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final nationalId = nationalIdController.text.trim();
    final universityEmail = universityEmailController.text.trim();
    final department = selectedDepartment ?? '';
    final studyYear = selectedStudyYear ?? '';
    final userType = selectedUserType ?? 'طالب';

    print('📝 بيانات التسجيل:');
    print('الاسم: $name');
    print('البريد الإلكتروني: $email');
    print('النوع: $userType');
    print('القسم: $department');
    print('السنة الدراسية: $studyYear');

    // التحقق من الحقول الأساسية
    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      errorMessage = 'يرجى ملء كل الحقول الإلزامية';
      print('❌ فشل التسجيل: $errorMessage');
      notifyListeners();
      return false;
    }

    // تحقق من تطابق كلمة المرور
    if (!isPasswordMatched) {
      errorMessage = 'كلمة المرور غير متطابقة';
      print('❌ فشل التسجيل: $errorMessage');
      notifyListeners();
      return false;
    }

    // التحقق حسب نوع المستخدم
    if (userType == 'طالب') {
      if (nationalId.isEmpty ||
          universityEmail.isEmpty ||
          department.isEmpty ||
          studyYear.isEmpty) {
        errorMessage = 'يرجى ملء كل الحقول الإلزامية للطالب';
        print('❌ فشل التسجيل: $errorMessage');
        notifyListeners();
        return false;
      }
      extractNationalIdData(nationalId);
      if (birthDate == null || gender == null || city == null) {
        errorMessage = 'الرقم القومي غير صحيح';
        print('❌ فشل التسجيل: $errorMessage');
        notifyListeners();
        return false;
      }
    } else {
      // للدكاترة والمعيدين: تحقق من الاسم، البريد الإلكتروني، الرقم القومي، كلمة المرور فقط
      if (nationalId.isEmpty) {
        errorMessage = 'يرجى إدخال الرقم القومي';
        print('❌ فشل التسجيل: $errorMessage');
        notifyListeners();
        return false;
      }
      extractNationalIdData(nationalId);
      if (birthDate == null || gender == null || city == null) {
        errorMessage = 'الرقم القومي غير صحيح';
        print('❌ فشل التسجيل: $errorMessage');
        notifyListeners();
        return false;
      }
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      print('⏳ إرسال بيانات التسجيل إلى AuthService...');
      final response = await AuthService.signUp(
        email: email,
        password: password,
      );
      final user = response?.user;
      if (user != null) {
        print('✅ تم إنشاء المستخدم بنجاح، ID: ${user.id}');
        print('⏳ حفظ بيانات المستخدم في قاعدة البيانات...');
        await UserService.saveUserProfile(
          uid: user.id,
          data: {
            'full_name': name,
            'email': email,
            'university_email': userType == 'طالب' ? universityEmail : null,
            'national_id': nationalId,
            'birth_date': birthDateString,
            'gender': gender,
            'city': city,
            'department': userType == 'طالب' ? department : null,
            'study_year': userType == 'طالب' ? studyYear : null,
            'user_type': userType,
          },
        );
        print('✅ تم حفظ البيانات بنجاح');
        return true;
      } else {
        errorMessage = 'لم يتم إنشاء الحساب';
        print('❌ فشل التسجيل: $errorMessage');
        return false;
      }
    } on AuthException catch (e) {
      errorMessage = e.message;
      print('❌ AuthException: ${e.message}');
      return false;
    } catch (e) {
      print('❌ حدث خطأ غير متوقع: $e');
      errorMessage = 'حدث خطأ غير متوقع';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // دوال لتبديل إظهار/إخفاء كلمة المرور
  void toggleShowPassword() {
    showPassword = !showPassword;
    notifyListeners();
  }

  void toggleShowConfirmPassword() {
    showConfirmPassword = !showConfirmPassword;
    notifyListeners();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    nationalIdController.dispose();
    universityEmailController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
