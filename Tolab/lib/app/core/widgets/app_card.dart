import 'package:flutter/material.dart';

import '../colors/app_colors.dart';
import '../constants/app_constants.dart';
import '../animations/app_motion.dart';
import '../spacing/app_spacing.dart';

class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    this.height,
    this.width,
    this.onTap,
    this.interactive = false,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = AppConstants.cardRadius,
    this.showShadow = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? height;
  final double? width;
  final VoidCallback? onTap;
  final bool interactive;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final bool showShadow;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        widget.backgroundColor ?? Theme.of(context).cardColor;
    final borderColor =
        widget.borderColor ??
        (isDark ? AppColors.strokeDark : AppColors.strokeLight);
    final shadowColor = isDark ? AppColors.shadowDark : AppColors.shadowLight;
    final hoverLift = widget.interactive && _isHovered;

    return MouseRegion(
      cursor: widget.onTap != null || widget.interactive
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      onEnter: widget.interactive || widget.onTap != null
          ? (_) => setState(() => _isHovered = true)
          : null,
      onExit: widget.interactive || widget.onTap != null
          ? (_) => setState(() => _isHovered = false)
          : null,
      child: AnimatedScale(
        scale: hoverLift ? 1.01 : 1,
        duration: AppMotion.fast,
        curve: AppMotion.emphasized,
        child: AnimatedContainer(
          duration: AppMotion.medium,
          curve: AppMotion.emphasized,
          transform: Matrix4.translationValues(0, hoverLift ? -3 : 0, 0),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(color: borderColor),
            boxShadow: widget.showShadow
                ? [
                    BoxShadow(
                      color: shadowColor.withValues(
                        alpha: hoverLift ? 0.18 : 0.11,
                      ),
                      blurRadius: hoverLift ? 34 : 22,
                      offset: Offset(0, hoverLift ? 18 : 12),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              onTap: widget.onTap,
              child: SizedBox(
                height: widget.height,
                width: widget.width,
                child: Padding(padding: widget.padding, child: widget.child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
