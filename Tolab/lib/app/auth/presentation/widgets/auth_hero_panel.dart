import 'package:flutter/material.dart';

class UnifiedAuthHeroPanel extends StatelessWidget {
  const UnifiedAuthHeroPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 980;

    return Container(
      padding: EdgeInsets.all(compact ? 24 : 40),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(compact ? 28 : 36),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B1220), Color(0xFF10264A), Color(0xFF1D4ED8)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A0F172A),
            blurRadius: 44,
            offset: Offset(0, 24),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: const [
              _GlassBadge(
                icon: Icons.verified_user_rounded,
                label: 'Unified university access',
              ),
              _GlassBadge(
                icon: Icons.auto_awesome_rounded,
                label: 'Backend-resolved roles',
              ),
            ],
          ),
          SizedBox(height: compact ? 24 : 32),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Text(
              'One polished sign-in surface for every Tolab workspace.',
              style: theme.textTheme.displaySmall?.copyWith(
                color: Colors.white,
                fontSize: compact ? 32 : 42,
                height: 1.02,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.8,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Text(
              'Admins, doctors, and assistants use the same secure entry point. After authentication, the backend resolves identity, permissions, and destination automatically.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.78),
                fontSize: compact ? 15 : 16,
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: compact ? 24 : 30),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: const [
              _SignalCard(
                icon: Icons.account_tree_outlined,
                title: 'No role picker',
                subtitle:
                    'The backend routes each user to the correct workspace.',
              ),
              _SignalCard(
                icon: Icons.shield_outlined,
                title: 'Shared session control',
                subtitle:
                    'Protected navigation, persistent sessions, one logout path.',
              ),
              _SignalCard(
                icon: Icons.devices_outlined,
                title: 'Responsive by design',
                subtitle:
                    'Optimized for phones, laptops, and wide desktop screens.',
              ),
            ],
          ),
          SizedBox(height: compact ? 24 : 32),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(compact ? 18 : 22),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            ),
            child: const Column(
              children: [
                _HeroInsightRow(
                  icon: Icons.space_dashboard_rounded,
                  title: 'Admin command center',
                  subtitle:
                      'System oversight, user governance, and institutional workflows.',
                ),
                SizedBox(height: 14),
                _HeroInsightRow(
                  icon: Icons.local_hospital_outlined,
                  title: 'Doctor teaching workspace',
                  subtitle:
                      'Course delivery, content operations, and teaching intelligence.',
                ),
                SizedBox(height: 14),
                _HeroInsightRow(
                  icon: Icons.support_agent_rounded,
                  title: 'Assistant operations lane',
                  subtitle:
                      'Day-to-day academic coordination with the right scoped access.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassBadge extends StatelessWidget {
  const _GlassBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _SignalCard extends StatelessWidget {
  const _SignalCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 180, maxWidth: 240),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.74),
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroInsightRow extends StatelessWidget {
  const _HeroInsightRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.76),
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
