import 'package:flutter/material.dart';

import '../../../../core/ui/tokens/color_tokens.dart';
import '../../../../core/ui/tokens/radius_tokens.dart';

class AuthFeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const AuthFeatureChip({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: AppRadius.rXl,
        border: Border.all(color: Colors.white.withValues(alpha: 0.85)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.grey800,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
