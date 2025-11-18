// features/auth/presentation/pages/login_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../bloc/auth_event.dart';
import '../widgets/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }

              // if (state is Authenticated) {
              //   final role = state.user.role;
              //   if (role == 'admin') {
              //    Navigator.pushReplacementNamed(context, '/adminDashboard');
              //    }
              //   else if (role == 'teacher') {
              //     Navigator.pushReplacementNamed(context, '/teacherDashboard');
              //    }
              //   else if (role == 'student') {
              //     Navigator.pushReplacementNamed(context, '/studentDashboard');
              //    }
              //   else if (role == 'parent') {
              //     Navigator.pushReplacementNamed(context, '/parentDashboard');
              //    }
              // }
            },
            builder: (context, state) {
              final bool isLoading = state is AuthLoading;

              final size = MediaQuery.of(context).size;
              final bottomPadding = MediaQuery.of(context).padding.bottom;

              return Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      height: size.height * 0.45,
                      width: double.infinity,
                      child: Lottie.asset(
                        'assets/lottie/login_sky.json',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.fromLTRB(
                        24,
                        32,
                        24,
                        24 + bottomPadding,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Center(
                              child: Text(
                                'تسجيل الدخول',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // الفورم
                            LoginForm(
                              isLoading: isLoading,
                              onSubmit: (email, password, rememberMe) {
                                context.read<AuthBloc>().add(
                                  LoginRequested(email, password),
                                );
                                // TODO: لو عايز تستخدم rememberMe في الـ LocalStorage بعدين
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
