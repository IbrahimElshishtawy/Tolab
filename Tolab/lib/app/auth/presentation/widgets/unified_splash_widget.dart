import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../app_admin/core/colors/app_colors.dart';

class UnifiedSplashWidget extends StatefulWidget {
  const UnifiedSplashWidget({
    super.key,
    this.showLoadingIndicator = true,
    this.logoAnimation,
  });

  final bool showLoadingIndicator;
  final Animation<double>? logoAnimation;

  @override
  State<UnifiedSplashWidget> createState() => _UnifiedSplashWidgetState();
}

class _UnifiedSplashWidgetState extends State<UnifiedSplashWidget>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _continuousController;

  late final Animation<double> _logoEntranceAnimation;
  late final Animation<double> _titleFadeAnimation;
  late final Animation<Offset> _titleSlideAnimation;
  late final Animation<double> _subtitleFadeAnimation;
  late final Animation<Offset> _subtitleSlideAnimation;
  late final Animation<double> _progressFadeAnimation;

  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _continuousController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    _logoEntranceAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
    );

    _titleFadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
    );

    _titleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _subtitleFadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.45, 0.9, curve: Curves.easeOut),
    );

    _subtitleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.45, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _progressFadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
    );

    // Generate random floating particles
    final rand = math.Random();
    for (int i = 0; i < 22; i++) {
      _particles.add(
        Particle(
          x: rand.nextDouble(),
          y: rand.nextDouble(),
          size: rand.nextDouble() * 3.5 + 1.5, // 1.5 to 5.0 pixels
          speed: rand.nextDouble() * 0.06 + 0.02, // slow drift speed
          swayAmplitude: rand.nextDouble() * 0.02 + 0.01,
          swaySpeed: rand.nextDouble() * 1.0 + 0.4,
          opacity: rand.nextDouble() * 0.25 + 0.15, // 0.15 to 0.4 opacity
        ),
      );
    }

    // Start the entrance and continuous animations
    _entranceController.forward();
    _continuousController.repeat();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _continuousController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget logo = ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Image.asset(
        'assets/icons/iconapp.png',
        width: 130,
        height: 130,
        fit: BoxFit.contain,
      ),
    );

    // Apply combined entry animations + continuous floating (bobbing/swaying) effects
    logo = AnimatedBuilder(
      animation: Listenable.merge([
        _entranceController,
        _continuousController,
        if (widget.logoAnimation != null) widget.logoAnimation!,
      ]),
      builder: (context, child) {
        final entranceVal = widget.logoAnimation?.value ?? _logoEntranceAnimation.value;
        
        // Gentle up/down floating (bobbing)
        final bobOffset = math.sin(_continuousController.value * 2 * math.pi) * 6.0;
        
        // Subtle constant rotation oscillation
        final spinAngle = math.sin(_continuousController.value * 2 * math.pi) * 0.015;

        return Transform.translate(
          offset: Offset(0, bobOffset),
          child: Transform.rotate(
            angle: spinAngle + (1.0 - entranceVal) * -0.15,
            child: Transform.scale(
              scale: entranceVal,
              child: Opacity(
                opacity: entranceVal.clamp(0.0, 1.0),
                child: child,
              ),
            ),
          ),
        );
      },
      child: logo,
    );

    return Scaffold(
      body: Container(
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
            // Dynamic/Breathing Blurred Background Orbs
            Positioned(
              top: -120,
              left: -40,
              child: _AnimatedBackgroundOrb(
                size: 320,
                color: const Color(0x452563EB),
                animation: _continuousController,
                offsetX: 15,
                offsetY: 20,
              ),
            ),
            Positioned(
              right: -80,
              top: 120,
              child: _AnimatedBackgroundOrb(
                size: 280,
                color: const Color(0x350EA5E9),
                animation: _continuousController,
                offsetX: -20,
                offsetY: 15,
              ),
            ),
            Positioned(
              left: 120,
              bottom: -120,
              child: _AnimatedBackgroundOrb(
                size: 260,
                color: const Color(0x2216A34A),
                animation: _continuousController,
                offsetX: 25,
                offsetY: -15,
              ),
            ),

            // Drifting Glow Particles in the background
            _FloatingParticles(
              particles: _particles,
              animation: _continuousController,
            ),

            // Main Content Column
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with a pulsating ambient glow halo behind it
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _continuousController,
                        builder: (context, _) {
                          final scale = 1.0 + (math.sin(_continuousController.value * 2 * math.pi) * 0.08);
                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: (isDark ? const Color(0xFF2563EB) : const Color(0xFF60A5FA))
                                        .withValues(alpha: isDark ? 0.22 : 0.16),
                                    blurRadius: 44,
                                    spreadRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      logo,
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Staggered entering Title with Blue-to-Purple gradient mask
                  AnimatedBuilder(
                    animation: _entranceController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _titleFadeAnimation.value,
                        child: Transform.translate(
                          offset: _titleSlideAnimation.value * 80.0,
                          child: child,
                        ),
                      );
                    },
                    child: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: isDark
                            ? const [
                                Color(0xFF60A5FA),
                                Color(0xFF818CF8),
                                Color(0xFFC084FC),
                              ]
                            : const [
                                Color(0xFF1E40AF),
                                Color(0xFF2563EB),
                                Color(0xFF6366F1),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Text(
                        'TOLAB',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 6,
                          color: Colors.white, // Required white color for ShaderMask to work correctly
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Staggered entering Arabic Subtitle
                  AnimatedBuilder(
                    animation: _entranceController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _subtitleFadeAnimation.value,
                        child: Transform.translate(
                          offset: _subtitleSlideAnimation.value * 60.0,
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      'وصول جامعي موحّد',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  // Custom elegant progress indicator (only when loading)
                  if (widget.showLoadingIndicator) ...[
                    AnimatedBuilder(
                      animation: _entranceController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _progressFadeAnimation.value,
                          child: child,
                        );
                      },
                      child: Column(
                        children: [
                          const SizedBox(height: 52),
                          Container(
                            width: 160,
                            height: 5,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.06)
                                  : Colors.black.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.black.withValues(alpha: 0.04),
                                width: 0.5,
                              ),
                            ),
                            child: const ClipRRect(
                              borderRadius: BorderRadius.all(Radius.circular(3)),
                              child: _ShimmeringProgressBar(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
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
          ),
        ),
      ),
    );
  }
}

class _AnimatedBackgroundOrb extends StatelessWidget {
  const _AnimatedBackgroundOrb({
    required this.size,
    required this.color,
    required this.animation,
    required this.offsetX,
    required this.offsetY,
  });

  final double size;
  final Color color;
  final Animation<double> animation;
  final double offsetX;
  final double offsetY;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        // Slowly shift position and scale
        final scale = 1.0 + (math.sin(animation.value * 2 * math.pi) * 0.12);
        final xShift = math.cos(animation.value * 2 * math.pi) * offsetX;
        final yShift = math.sin(animation.value * 2 * math.pi) * offsetY;

        return Transform.translate(
          offset: Offset(xShift, yShift),
          child: Transform.scale(
            scale: scale,
            child: _BackgroundOrb(size: size, color: color),
          ),
        );
      },
    );
  }
}

class Particle {
  double x;
  double y;
  double size;
  double speed;
  double swayAmplitude;
  double swaySpeed;
  double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.swayAmplitude,
    required this.swaySpeed,
    required this.opacity,
  });
}

class _FloatingParticles extends StatelessWidget {
  const _FloatingParticles({
    required this.particles,
    required this.animation,
  });

  final List<Particle> particles;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlePainter(
            particles: particles,
            animationValue: animation.value,
            isDark: Theme.of(context).brightness == Brightness.dark,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({
    required this.particles,
    required this.animationValue,
    required this.isDark,
  });

  final List<Particle> particles;
  final double animationValue;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final particleColor = isDark
        ? const Color(0xFF60A5FA)
        : const Color(0xFF2563EB);

    for (final p in particles) {
      // Calculate animated vertical position with wrapping (drifts upwards)
      double yCurrent = p.y - (animationValue * p.speed);
      yCurrent = yCurrent % 1.0;

      // Calculate horizontal swaying motion
      final sway = math.sin(animationValue * 2 * math.pi * p.swaySpeed) * p.swayAmplitude;
      double xCurrent = (p.x + sway) % 1.0;

      final dx = xCurrent * size.width;
      final dy = yCurrent * size.height;

      // Fade out smoothly at top and bottom boundaries
      double edgeFade = 1.0;
      if (yCurrent < 0.15) {
        edgeFade = yCurrent / 0.15;
      } else if (yCurrent > 0.85) {
        edgeFade = (1.0 - yCurrent) / 0.15;
      }

      paint.color = particleColor.withValues(alpha: p.opacity * edgeFade);
      canvas.drawCircle(Offset(dx, dy), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class _ShimmeringProgressBar extends StatefulWidget {
  const _ShimmeringProgressBar();

  @override
  State<_ShimmeringProgressBar> createState() => _ShimmeringProgressBarState();
}

class _ShimmeringProgressBarState extends State<_ShimmeringProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final val = _controller.value;
        // Sliding indicator block from left to right
        final alignX = -1.0 + (val * 2.0);
        
        return Align(
          alignment: Alignment(alignX, 0),
          child: FractionallySizedBox(
            widthFactor: 0.45,
            child: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2563EB),
                    Color(0xFF0EA5E9),
                    Color(0xFF6366F1),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
