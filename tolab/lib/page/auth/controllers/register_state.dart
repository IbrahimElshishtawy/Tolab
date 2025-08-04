abstract class RegisterState {
  const RegisterState();
}

class RegisterInitial extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterSuccess extends RegisterState {}

class RegisterFailure extends RegisterState {
  final String message;
  const RegisterFailure(this.message);
}

class RegisterUserTypeChanged extends RegisterState {
  final String userType;
  const RegisterUserTypeChanged(this.userType);
}

class RegisterRoleChanged extends RegisterState {
  final String role;
  const RegisterRoleChanged(this.role);
}

class RegisterDepartmentChanged extends RegisterState {
  final String? department;
  const RegisterDepartmentChanged(this.department);
}

class RegisterStudyYearChanged extends RegisterState {
  final String? year;
  const RegisterStudyYearChanged(this.year);
}

class RegisterNationalIdExtracted extends RegisterState {
  final String birthDate;
  final String gender;
  const RegisterNationalIdExtracted({
    required this.birthDate,
    required this.gender,
  });
}
