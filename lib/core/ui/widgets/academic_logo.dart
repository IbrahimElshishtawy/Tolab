import 'package:flutter/material.dart';
import '../tokens/color_tokens.dart';

class AcademicLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const AcademicLogo({
    super.key,
    this.size = 100,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.account_balance_rounded,
                size: size * 0.5,
                color: Colors.white,
              ),
              Positioned(
                bottom: size * 0.15,
                child: Container(
                  height: size * 0.08,
                  width: size * 0.4,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 16),
          Text(
            'UNIVERSITY',
            style: TextStyle(
              fontSize: size * 0.25,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
              color: AppColors.primary,
            ),
          ),
          Text(
            'PORTAL SYSTEM',
            style: TextStyle(
              fontSize: size * 0.12,
              fontWeight: FontWeight.w500,
              letterSpacing: 2,
              color: AppColors.primary.withOpacity(0.7),
            ),
          ),
        ],
      ],
    );
  }
}
