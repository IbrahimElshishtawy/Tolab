import 'dart:ui';

import 'package:flutter/material.dart';

class DashboardShell extends StatelessWidget {
  final Widget child;
  final Widget? topBackground;

  const DashboardShell({
    super.key,
    required this.child,
    this.topBackground,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            const Positioned.fill(child: _DashboardBackdrop()),
            if (topBackground != null) topBackground!,
            child,
          ],
        ),
      ),
    );
  }
}

class _DashboardBackdrop extends StatelessWidget {
  const _DashboardBackdrop();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF7FAFF),
            Color(0xFFF3F6FB),
            Color(0xFFEFF3F9),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -40,
            child: _BlurBubble(
              size: 260,
              colors: const [Color(0x99CDE0FF), Color(0x5599B8FF)],
            ),
          ),
          Positioned(
            top: 180,
            left: -80,
            child: _BlurBubble(
              size: 220,
              colors: const [Color(0x88FFFFFF), Color(0x44C9D9F7)],
            ),
          ),
        ],
      ),
    );
  }
}

class _BlurBubble extends StatelessWidget {
  final double size;
  final List<Color> colors;

  const _BlurBubble({
    required this.size,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: colors),
        ),
      ),
    );
  }
}

class DashboardOrb extends StatelessWidget {
  final double size;
  final List<Color> colors;
  final double top;
  final double? left;
  final double? right;

  const DashboardOrb({
    super.key,
    required this.size,
    required this.colors,
    required this.top,
    this.left,
    this.right,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: IgnorePointer(
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: colors),
              boxShadow: [
                BoxShadow(
                  color: colors.last.withValues(alpha: 0.18),
                  blurRadius: 40,
                  spreadRadius: 8,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardSectionTitle extends StatelessWidget {
  final String title;
  final String actionLabel;
  final String? subtitle;

  const DashboardSectionTitle({
    super.key,
    required this.title,
    required this.actionLabel,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF182230),
                      letterSpacing: -0.3,
                    ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE1E8F3)),
              ),
              child: Text(
                actionLabel,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF3A71D9),
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF718198),
                  height: 1.45,
                ),
          ),
        ],
      ],
    );
  }
}

class DashboardHeroCard extends StatelessWidget {
  final String badge;
  final IconData badgeIcon;
  final String title;
  final String description;
  final List<Color> gradient;
  final List<Widget> footer;
  final Widget? trailing;

  const DashboardHeroCard({
    super.key,
    required this.badge,
    required this.badgeIcon,
    required this.title,
    required this.description,
    required this.gradient,
    required this.footer,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.20),
            blurRadius: 32,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -34,
            right: -12,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.10),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(badgeIcon, color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          badge,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (trailing != null) trailing!,
                ],
              ),
              const SizedBox(height: 22),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 29,
                  fontWeight: FontWeight.w800,
                  height: 1.08,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: const TextStyle(
                  color: Color(0xFFD8E6FF),
                  fontSize: 14,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: footer,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HeroMetricChip extends StatelessWidget {
  final String value;
  final String label;

  const HeroMetricChip({
    super.key,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: 112,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFFD6E7FF),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardInfoPanel extends StatelessWidget {
  final Widget child;

  const DashboardInfoPanel({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.80),
                const Color(0xFFF7FAFF).withValues(alpha: 0.72),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFE2EAF6)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A10233F),
                blurRadius: 24,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
