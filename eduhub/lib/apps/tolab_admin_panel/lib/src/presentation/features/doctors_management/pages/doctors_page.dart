// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';

class doctors_pagePage extends StatelessWidget {
  const doctors_pagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'doctors_page',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: const Center(
        child: Text('doctors_page Page', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
