import 'package:flutter/material.dart';

class SectionsScreen extends StatelessWidget {
  final int subjectId;
  const SectionsScreen({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Sections List'));
  }
}
