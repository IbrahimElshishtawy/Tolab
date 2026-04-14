import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_radii.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/dashboard_theme_tokens.dart';

class DoctorHomeLoading extends StatelessWidget {
  const DoctorHomeLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final metricWidth = _metricCardWidth(width);
        final sectionWidth = _sectionCardWidth(width);
        final sectionChildren = [
          SizedBox(
            width: sectionWidth,
            child: const _LoadingListSection(
              titleWidthFactor: 0.36,
              itemCount: 3,
              includeMetaRow: true,
            ),
          ),
          SizedBox(
            width: sectionWidth,
            child: const _LoadingListSection(
              titleWidthFactor: 0.42,
              itemCount: 4,
              includeMetaRow: false,
            ),
          ),
          SizedBox(width: sectionWidth, child: const _LoadingDetailSection()),
          SizedBox(
            width: sectionWidth,
            child: const _LoadingListSection(
              titleWidthFactor: 0.30,
              itemCount: 3,
              includeMetaRow: true,
            ),
          ),
        ];

        return Shimmer.fromColors(
          baseColor: tokens.surfaceAlt,
          highlightColor: tokens.surface,
          child: ListView(
            padding: const EdgeInsets.all(DashboardAppSpacing.xl),
            children: [
              const _LoadingHeroCard(),
              const SizedBox(height: DashboardAppSpacing.lg),
              Wrap(
                spacing: DashboardAppSpacing.md,
                runSpacing: DashboardAppSpacing.md,
                children: List.generate(
                  4,
                  (_) => SizedBox(
                    width: metricWidth,
                    child: const _LoadingMetricCard(),
                  ),
                ),
              ),
              const SizedBox(height: DashboardAppSpacing.lg),
              Wrap(
                spacing: DashboardAppSpacing.lg,
                runSpacing: DashboardAppSpacing.lg,
                children: sectionChildren,
              ),
            ],
          ),
        );
      },
    );
  }

  double _metricCardWidth(double width) {
    if (width >= 1240) {
      return (width - (DashboardAppSpacing.md * 3)) / 4;
    }
    if (width >= 780) {
      return (width - DashboardAppSpacing.md) / 2;
    }
    return width;
  }

  double _sectionCardWidth(double width) {
    if (width >= 1240) {
      return (width - DashboardAppSpacing.lg) / 2;
    }
    return width;
  }
}

class _LoadingHeroCard extends StatelessWidget {
  const _LoadingHeroCard();

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);

    return Container(
      padding: const EdgeInsets.all(DashboardAppSpacing.xl),
      decoration: BoxDecoration(
        gradient: tokens.heroGradient,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: tokens.border),
        boxShadow: DashboardAppShadows.elevated(tokens.shadow),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _LoadingCircle(size: 56),
              SizedBox(width: DashboardAppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LoadingBar(widthFactor: 0.48, height: 24),
                    SizedBox(height: DashboardAppSpacing.xs),
                    _LoadingBar(widthFactor: 0.74),
                  ],
                ),
              ),
              SizedBox(width: DashboardAppSpacing.md),
              _LoadingPill(width: 96),
            ],
          ),
          const SizedBox(height: DashboardAppSpacing.lg),
          Wrap(
            spacing: DashboardAppSpacing.sm,
            runSpacing: DashboardAppSpacing.sm,
            children: const [
              _LoadingPill(width: 88),
              _LoadingPill(width: 104),
              _LoadingPill(width: 112),
              _LoadingPill(width: 92),
            ],
          ),
          const SizedBox(height: DashboardAppSpacing.lg),
          Wrap(
            spacing: DashboardAppSpacing.sm,
            runSpacing: DashboardAppSpacing.sm,
            children: const [
              _LoadingPill(width: 124, height: 44, radius: 18),
              _LoadingPill(width: 156, height: 44, radius: 18),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoadingMetricCard extends StatelessWidget {
  const _LoadingMetricCard();

  @override
  Widget build(BuildContext context) {
    return _LoadingCard(
      padding: const EdgeInsets.all(DashboardAppSpacing.lg),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _LoadingCircle(size: 42),
              Spacer(),
              _LoadingPill(width: 68, height: 26),
            ],
          ),
          SizedBox(height: DashboardAppSpacing.lg),
          _LoadingBar(widthFactor: 0.38, height: 26),
          SizedBox(height: DashboardAppSpacing.sm),
          _LoadingBar(widthFactor: 0.56),
          SizedBox(height: DashboardAppSpacing.xs),
          _LoadingBar(widthFactor: 0.72),
        ],
      ),
    );
  }
}

class _LoadingListSection extends StatelessWidget {
  const _LoadingListSection({
    required this.titleWidthFactor,
    required this.itemCount,
    required this.includeMetaRow,
  });

  final double titleWidthFactor;
  final int itemCount;
  final bool includeMetaRow;

  @override
  Widget build(BuildContext context) {
    return _LoadingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LoadingBar(widthFactor: titleWidthFactor, height: 22),
          const SizedBox(height: DashboardAppSpacing.xs),
          const _LoadingBar(widthFactor: 0.62),
          const SizedBox(height: DashboardAppSpacing.md),
          ...List.generate(itemCount, (index) {
            final isLast = index == itemCount - 1;
            return Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 0 : DashboardAppSpacing.md,
              ),
              child: _LoadingListItem(includeMetaRow: includeMetaRow),
            );
          }),
        ],
      ),
    );
  }
}

class _LoadingDetailSection extends StatelessWidget {
  const _LoadingDetailSection();

  @override
  Widget build(BuildContext context) {
    return _LoadingCard(
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LoadingBar(widthFactor: 0.34, height: 22),
          SizedBox(height: DashboardAppSpacing.xs),
          _LoadingBar(widthFactor: 0.54),
          SizedBox(height: DashboardAppSpacing.md),
          _LoadingBar(widthFactor: 0.88),
          SizedBox(height: DashboardAppSpacing.sm),
          _LoadingBar(widthFactor: 0.94),
          SizedBox(height: DashboardAppSpacing.sm),
          _LoadingBar(widthFactor: 0.58),
          SizedBox(height: DashboardAppSpacing.lg),
          Wrap(
            spacing: DashboardAppSpacing.sm,
            runSpacing: DashboardAppSpacing.sm,
            children: [
              _LoadingPill(width: 90),
              _LoadingPill(width: 104),
              _LoadingPill(width: 82),
            ],
          ),
          SizedBox(height: DashboardAppSpacing.lg),
          _LoadingBar(widthFactor: 0.46),
          SizedBox(height: DashboardAppSpacing.sm),
          _LoadingBar(widthFactor: 0.92),
          SizedBox(height: DashboardAppSpacing.sm),
          _LoadingBar(widthFactor: 0.84),
        ],
      ),
    );
  }
}

class _LoadingListItem extends StatelessWidget {
  const _LoadingListItem({required this.includeMetaRow});

  final bool includeMetaRow;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);

    return Container(
      padding: const EdgeInsets.all(DashboardAppSpacing.md),
      decoration: BoxDecoration(
        color: tokens.surfaceAlt,
        borderRadius: BorderRadius.circular(DashboardAppRadii.xl),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _LoadingCircle(size: 42),
              SizedBox(width: DashboardAppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LoadingBar(widthFactor: 0.52),
                    SizedBox(height: DashboardAppSpacing.sm),
                    _LoadingBar(widthFactor: 0.84),
                  ],
                ),
              ),
              SizedBox(width: DashboardAppSpacing.sm),
              _LoadingPill(width: 72, height: 28),
            ],
          ),
          if (includeMetaRow) ...[
            const SizedBox(height: DashboardAppSpacing.sm),
            const Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: DashboardAppSpacing.xs,
                runSpacing: DashboardAppSpacing.xs,
                children: [
                  _LoadingPill(width: 78, height: 24),
                  _LoadingPill(width: 92, height: 24),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({
    required this.child,
    this.padding = const EdgeInsets.all(DashboardAppSpacing.lg),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: tokens.border),
        boxShadow: DashboardAppShadows.soft(tokens.shadow),
      ),
      child: child,
    );
  }
}

class _LoadingBar extends StatelessWidget {
  const _LoadingBar({required this.widthFactor, this.height = 14});

  final double widthFactor;
  final double height;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);

    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: tokens.surface,
          borderRadius: BorderRadius.circular(height),
        ),
      ),
    );
  }
}

class _LoadingPill extends StatelessWidget {
  const _LoadingPill({
    required this.width,
    this.height = 32,
    this.radius = 999,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _LoadingCircle extends StatelessWidget {
  const _LoadingCircle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);

    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(color: tokens.surface, shape: BoxShape.circle),
    );
  }
}
