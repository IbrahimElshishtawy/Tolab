import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tolab_fci/features/auth/presentation/widgets/Login_Card.dart';
import 'package:tolab_fci/features/splash/presentation/widgets/splash_background.dart';
import 'package:tolab_fci/features/splash/presentation/widgets/Tolab_Logo_Icon_write(T).dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String selectedRole = 'student';
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SplashBackground(
      child: Stack(
        children: [
          Positioned(
            top: 108,
            right: 24,
            child: Hero(
              tag: 'tolab_logo',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  TolabLogoBox(),
                  SizedBox(width: 7),
                  Text(
                    'OLAB',
                    style: TextStyle(
                      fontSize: 24,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            top: MediaQuery.of(context).size.height * 0.23,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 220,
                height: 220,
                child: Lottie.asset('assets/lottie/login.json'),
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 0),
              child: LoginCard(
                selectedRole: selectedRole,
                emailController: emailController,
                onRoleChanged: (value) {
                  setState(() {
                    selectedRole = value;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
