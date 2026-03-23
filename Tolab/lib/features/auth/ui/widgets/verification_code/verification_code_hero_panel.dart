import 'package:flutter/material.dart';

import '../../../../../core/ui/tokens/color_tokens.dart';
import '../../../../../core/ui/tokens/radius_tokens.dart';

class VerificationCodeHeroPanel extends StatelessWidget {
  final bool compact;
  final String timerText;

  const VerificationCodeHeroPanel({
    super.key,
    required this.compact,
    required this.timerText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        right: compact ? 0 : 24,
        top: compact ? 8 : 56,
        bottom: compact ? 8 : 56,
      ),
      child: Column(
        crossAxisAlignment:
            compact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: AppRadius.rXl,
              border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.verified_rounded, color: AppColors.primary, size: 18),
                SizedBox(width: 8),
                Text(
                  'Email verification',
                  style: TextStyle(
                    color: AppColors.grey800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: compact ? 18 : 28),
          Text(
            'Confirm your code',
            textAlign: compact ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              fontSize: compact ? 30 : 42,
              fontWeight: FontWeight.w800,
              height: 1.05,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Enter the 4-digit code sent to your email. The current code expires in $timerText.',
            textAlign: compact ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              fontSize: compact ? 15 : 17,
              height: 1.6,
              color: AppColors.grey700,
            ),
          ),
        ],
      ),
    );
  }
}
