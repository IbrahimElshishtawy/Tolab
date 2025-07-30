// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

      addressController.text = 'محافظة القاهرة';
      notifyListeners();
    } catch (e) {
      // تجاهل الأخطاء
    }
  }

  // تنفيذ التسجيل في Firebase
  Future<void> register(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (!passwordsMatch) {
      showMessage(context, 'كلمة المرور غير متطابقة');
      return;
    }

    try {
      // إنشاء حساب في Firebase Auth
      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = userCredential.user!.uid;

      // حفظ البيانات في Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'fullName': fullNameController.text,
        'email': email,
        'nationalId': nationalIdController.text,
        'birthDate': birthDateController.text,
        'gender': genderController.text,
        'address': addressController.text,
        'userType': selectedUserType,
        'role': selectedRole,
        'department': selectedDepartment,
        'studyYear': selectedStudyYear,
        'uid': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance.collection('chats').add({
        'members': [uid],
        'type': 'self',
        'createdAt': FieldValue.serverTimestamp(),
      });

      showMessage(context, 'تم إنشاء الحساب بنجاح ✅');
    } on FirebaseAuthException catch (e) {
      showMessage(context, 'خطأ: ${e.message}');
    } catch (e) {
      showMessage(context, 'حدث خطأ غير متوقع');
    }
  }

  void showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

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
