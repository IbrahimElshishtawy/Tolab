import 'package:alp_animated_splashscreen/alp_animated_splashscreen.dart';
import 'package:flutter/material.dart';

class Splashscreen extends StatelessWidget {
  const Splashscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AnimatedSplashScreen(
      companyname: 'Alp Turnkey Solutions',
      brandnamecolor: Colors.orange,
      backgroundcolor: Colors.black,
      foregroundcolor: Colors.orange,
      logo: 'assets/icons/iconapp.jpg',
      brandname: 'Alp Turnkey Solutions',
    );
  }
}
