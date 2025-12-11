// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';

class academic_structure_pagePage extends StatelessWidget {
  const academic_structure_pagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'academic_structure_page',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: const Center(
        child: Text(
          'academic_structure_page Page',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
