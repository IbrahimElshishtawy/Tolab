import 'package:firebase_auth/firebase_auth.dart';

abstract class LoginState {
  const LoginState();
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {}

class LoginFailure extends LoginState {
  final String message;
  const LoginFailure(this.message);
}

class LoginPasswordVisibilityToggled extends LoginState {
  final bool isPasswordVisible;
  const LoginPasswordVisibilityToggled(this.isPasswordVisible);
}

class LoginRememberMeChanged extends LoginState {
  final bool value;
  const LoginRememberMeChanged(this.value);
}

class LoginLoadedSavedCredentials extends LoginState {
  final String email;
  final String password;
  final bool rememberMe;

  const LoginLoadedSavedCredentials({
    required this.email,
    required this.password,
    required this.rememberMe,
  });

  LoginLoadedSavedCredentials copyWith({
    String? email,
    String? password,
    bool? rememberMe,
  }) {
    return LoginLoadedSavedCredentials(
      email: email ?? this.email,
      password: password ?? this.password,
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }
}

class LoginGoogleSuccess extends LoginState {
  final User user;
  const LoginGoogleSuccess(this.user);
}
