import 'package:flutter/material.dart';

import 'app_text_field.dart';

class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.controller,
    this.onChanged,
    this.label = 'بحث',
    this.hintText = 'ابحث في المواد أو الكويزات أو الملخصات',
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String label;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: label,
      hintText: hintText,
      prefixIcon: Icons.search_rounded,
      onChanged: onChanged,
    );
  }
}
