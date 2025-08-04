import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(RegisterInitial());

  // Text controllers
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final nationalIdController = TextEditingController();
  final birthDateController = TextEditingController();
  final genderController = TextEditingController();
  final addressController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? selectedUserType;
  String? selectedRole;
  String? selectedDepartment;
  String? selectedStudyYear;

  bool get passwordsMatch =>
      passwordController.text == confirmPasswordController.text;

  get gender => null;

  get birthDate => null;

  get address => null;

  get departments => null;

  get academicYears => null;

  get obscurePassword => null;

  get togglePasswordVisibility => null;

  get obscureConfirmPassword => null;

  get toggleConfirmPasswordVisibility => null;

  void setUserType(String type) {
    selectedUserType = type;
    emit(RegisterUserTypeChanged(type));
  }

  void setRole(String role) {
    selectedRole = role;
    emit(RegisterRoleChanged(role));
  }

  void setDepartment(String? department) {
    selectedDepartment = department;
    emit(RegisterDepartmentChanged(department));
  }

  void setStudyYear(String? year) {
    selectedStudyYear = year;
    emit(RegisterStudyYearChanged(year));
  }

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

      emit(
        RegisterNationalIdExtracted(
          birthDate: birthDateController.text,
          gender: genderController.text,
        ),
      );
    } catch (_) {}
  }

  Future<void> register() async {
    emit(RegisterLoading());

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (!passwordsMatch) {
      emit(RegisterFailure('كلمتا المرور غير متطابقتين'));
      return;
    }

    try {
      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = userCredential.user!.uid;

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

      emit(RegisterSuccess());
    } on FirebaseAuthException catch (e) {
      emit(RegisterFailure(e.message ?? "حدث خطأ أثناء التسجيل"));
    } catch (e) {
      emit(RegisterFailure("حدث خطأ غير متوقع"));
    }
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
