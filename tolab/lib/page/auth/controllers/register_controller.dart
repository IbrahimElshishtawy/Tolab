import 'package:flutter/material.dart';

class RegisterController with ChangeNotifier {
  // Text controllers
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final nationalIdController = TextEditingController();
  final birthDateController = TextEditingController();
  final genderController = TextEditingController();
  final addressController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // قيم مختارة
  String? selectedUserType;
  String? selectedRole;
  String? selectedDepartment;
  String? selectedStudyYear;

  // التحقق من تطابق كلمتي المرور
  bool get passwordsMatch =>
      passwordController.text == confirmPasswordController.text;

  void checkPasswordMatch() {
    notifyListeners();
  }

  // ضبط الدور (طالب / دكتور / معيد)
  void setUserType(String type) {
    selectedUserType = type;
    notifyListeners();
  }

  void setRole(String role) {
    selectedRole = role;
    notifyListeners();
  }

  void setDepartment(String? department) {
    selectedDepartment = department;
    notifyListeners();
  }

  void setStudyYear(String? year) {
    selectedStudyYear = year;
    notifyListeners();
  }

  // استخراج بيانات الرقم القومي
  void extractNationalIdInfo(String nationalId) {
    if (nationalId.length < 14) return;

    try {
      String centuryDigit = nationalId[0];
      String year = nationalId.substring(1, 3);
      String month = nationalId.substring(3, 5);
      String day = nationalId.substring(5, 7);
      String genderDigit = nationalId[12];

      String fullYear = (centuryDigit == '2' ? '19' : '20') + year;
      birthDateController.text = '$day/$month/$fullYear';

      int genderValue = int.tryParse(genderDigit) ?? 1;
      genderController.text = genderValue % 2 == 0 ? 'أنثى' : 'ذكر';

      // مثال ثابت للعنوان (يمكنك التوصيل بقاعدة بيانات أو API لاحقًا)
      addressController.text = 'محافظة القاهرة';

      notifyListeners();
    } catch (e) {
      // تجاهل الخطأ في حال رقم قومي غير صحيح
    }
  }

  // تنفيذ التسجيل
  Future<void> register(BuildContext context) async {
    // هنا تقدر تربط مع Supabase أو أي خدمة أخرى
    debugPrint('تسجيل المستخدم...');
    debugPrint('الاسم: ${fullNameController.text}');
    debugPrint('البريد: ${emailController.text}');
    debugPrint('الدور: $selectedRole');
    debugPrint('النوع: $selectedUserType');
    debugPrint('القسم: $selectedDepartment');
    debugPrint('السنة: $selectedStudyYear');
    debugPrint('الرقم القومي: ${nationalIdController.text}');
    debugPrint('تاريخ الميلاد: ${birthDateController.text}');
    debugPrint('النوع: ${genderController.text}');
    debugPrint('العنوان: ${addressController.text}');

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم تسجيل المستخدم بنجاح')));
  }

  // Dispose لكل الكنترولات
  void disposeControllers() {
    fullNameController.dispose();
    emailController.dispose();
    nationalIdController.dispose();
    birthDateController.dispose();
    genderController.dispose();
    addressController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }
}
