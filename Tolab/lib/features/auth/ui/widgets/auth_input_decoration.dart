import 'package:flutter/material.dart';

import '../../../../core/ui/tokens/color_tokens.dart';
import '../../../../core/ui/tokens/radius_tokens.dart';

InputDecoration buildAuthInputDecoration({
  required String hintText,
  required IconData icon,
  Widget? suffixIcon,
  String? labelText,
}) {
  return InputDecoration(
    hintText: hintText,
    labelText: labelText,
    counterText: '',
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.9),
    prefixIcon: Icon(icon, color: AppColors.grey500),
    suffixIcon: suffixIcon,
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    enabledBorder: OutlineInputBorder(
      borderRadius: AppRadius.rL,
      borderSide: const BorderSide(color: Color(0xFFDCE4F2)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: AppRadius.rL,
      borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: AppRadius.rL,
      borderSide: const BorderSide(color: AppColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: AppRadius.rL,
      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
    ),
  );
}
