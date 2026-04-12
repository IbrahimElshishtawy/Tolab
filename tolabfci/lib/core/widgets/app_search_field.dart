import 'package:flutter/material.dart';

import 'app_text_field.dart';

class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.controller,
    this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: 'Search',
      hintText: 'Find subjects, quizzes, or summaries',
      prefixIcon: Icons.search_rounded,
      onChanged: onChanged,
    );
  }
}
