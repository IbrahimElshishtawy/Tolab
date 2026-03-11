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
      backgroundColor: const Color(0xFFF3F7FC),
      body: SafeArea(
        child: Stack(
          children: [
            if (topBackground != null) topBackground!,
            child,
          ],
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
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: colors),
            boxShadow: [
              BoxShadow(
                color: colors.last.withValues(alpha: 0.16),
                blurRadius: 36,
                spreadRadius: 8,
              ),
            ],
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
                      color: const Color(0xFF17212F),
                    ),
              ),
            ),
            Text(
              actionLabel,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF3469C8),
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6C7C92),
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
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.18),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
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
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              color: Color(0xFFD6E7FF),
              fontSize: 14,
              height: 1.5,
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
    return Container(
      width: 112,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFF6FAFF)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2EAF6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0E2A47),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}
