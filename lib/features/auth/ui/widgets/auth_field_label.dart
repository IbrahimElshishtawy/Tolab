import 'package:flutter/material.dart';

import '../../../../core/ui/tokens/color_tokens.dart';

class AuthFieldLabel extends StatelessWidget {
  final String text;

  const AuthFieldLabel({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.grey800,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
