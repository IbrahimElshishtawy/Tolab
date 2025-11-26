// splash_mobile.dart
import 'package:eduhub/router/app_routes..dart';
import 'package:flutter/material.dart';

class SplashMobile extends StatefulWidget {
  const SplashMobile({super.key});

  @override
  State<SplashMobile> createState() => _SplashMobileState();
}

class _SplashMobileState extends State<SplashMobile>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, AppRoutes.studentDesktopHome);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[700],
      body: const Center(
        child: Text(
          'TOLAB Mobile',
          style: TextStyle(color: Colors.white, fontSize: 30),
        ),
      ),
    );
  }
}
