import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../app_admin/core/colors/app_colors.dart';

class UnifiedAuthPageShell extends StatelessWidget {
  const UnifiedAuthPageShell({
    super.key,
    required this.hero,
    required this.form,
  });

  final Widget hero;
  final Widget form;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isDesktop = width >= 980;
        final horizontalPadding = width >= 1280
            ? 56.0
            : width >= 900
            ? 40.0
            : width >= 600
            ? 28.0
            : 18.0;
        final verticalPadding = isDesktop ? 36.0 : 20.0;

        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? const [
                      Color(0xFF08101C),
                      Color(0xFF0D1726),
                      Color(0xFF101B2D),
                    ]
                  : const [
                      Color(0xFFF5F7FB),
                      Color(0xFFEEF3FA),
                      Color(0xFFEAF1FF),
                    ],
            ),
          ),
          child: Stack(
            children: [
              const Positioned(
                top: -120,
                left: -40,
                child: _BackgroundOrb(size: 320, color: Color(0x662563EB)),
              ),
              const Positioned(
                right: -80,
                top: 120,
                child: _BackgroundOrb(size: 280, color: Color(0x4D0EA5E9)),
              ),
              const Positioned(
                left: 120,
                bottom: -120,
                child: _BackgroundOrb(size: 260, color: Color(0x3316A34A)),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - (verticalPadding * 2),
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1240),
                        child: isDesktop
                            ? _DesktopAuthLayout(hero: hero, form: form)
                            : _MobileAuthLayout(hero: hero, form: form),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DesktopAuthLayout extends StatelessWidget {
  const _DesktopAuthLayout({required this.hero, required this.form});

  final Widget hero;
  final Widget form;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(flex: 11, child: hero),
        const SizedBox(width: 28),
        Flexible(
          flex: 8,
          child: Align(
            alignment: Alignment.centerRight,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: form,
            ),
          ),
        ),
      ],
    );
  }
}

class _MobileAuthLayout extends StatelessWidget {
  const _MobileAuthLayout({required this.hero, required this.form});

  final Widget hero;
  final Widget form;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        hero,
        const SizedBox(height: 20),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: form,
        ),
      ],
    );
  }
}

class _BackgroundOrb extends StatelessWidget {
  const _BackgroundOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 56, sigmaY: 56),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(
              color: AppColors.surfaceLight.withValues(alpha: 0.18),
            ),
          ),
        ),
      ),
    );
  }
}
