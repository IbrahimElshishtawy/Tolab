import 'package:flutter/material.dart';

import '../../../../core/ui/tokens/color_tokens.dart';
import '../../../../core/ui/tokens/radius_tokens.dart';
import 'auth_feature_chip.dart';

class AuthHeroFeature {
  final IconData icon;
  final String label;

  const AuthHeroFeature({
    required this.icon,
    required this.label,
  });
}

class AuthHeroPanel extends StatelessWidget {
  final bool compact;
  final IconData badgeIcon;
  final String badgeLabel;
  final String title;
  final String subtitle;
  final List<AuthHeroFeature> features;

  const AuthHeroPanel({
    super.key,
    required this.badgeIcon,
    required this.badgeLabel,
    required this.title,
    required this.subtitle,
    required this.features,
    this.compact = false,
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
              children: [
                Icon(badgeIcon, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Text(
                  badgeLabel,
                  style: const TextStyle(
                    color: AppColors.grey800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: compact ? 18 : 28),
          Text(
            title,
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
            subtitle,
            textAlign: compact ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              fontSize: compact ? 15 : 17,
              height: 1.6,
              color: AppColors.grey700,
            ),
          ),
          SizedBox(height: compact ? 18 : 28),
          Wrap(
            alignment: compact ? WrapAlignment.center : WrapAlignment.start,
            spacing: 12,
            runSpacing: 12,
            children: features
                .map(
                  (feature) => AuthFeatureChip(
                    icon: feature.icon,
                    label: feature.label,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
