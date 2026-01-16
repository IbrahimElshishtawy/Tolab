// ignore_for_file: file_names

import 'dart:math';
import 'package:flutter/material.dart';

class TolabLogoBox extends StatelessWidget {
  const TolabLogoBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -pi / 5,
      child: Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          color: const Color.fromARGB(
            255,
            255,
            255,
            255,
          ), // rgba(2, 62, 197, 1)
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: const Text(
            'T',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color.fromARGB(255, 29, 35, 201),
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
