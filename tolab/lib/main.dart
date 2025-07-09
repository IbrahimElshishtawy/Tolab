// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:tolab/Screens/splash/splash_page.dart';

void main() {
  runApp(const tolab());
}

class tolab extends StatelessWidget {
  const tolab({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {'/splash': (context) => const SplashScreen()},
    );
  }
}
