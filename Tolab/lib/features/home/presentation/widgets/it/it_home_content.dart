import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:tolab_fci/features/home/presentation/widgets/dashboard_shell.dart';
import 'package:tolab_fci/features/home/presentation/widgets/home_header.dart';
import 'package:tolab_fci/features/home/presentation/widgets/quick_action_card.dart';
import 'package:tolab_fci/redux/app_state.dart';

import 'it_reports_panel.dart';
import 'it_status_card.dart';

class ItHomeContent extends StatelessWidget {
  const ItHomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, String?>(
      converter: (store) => store.state.authState.email,
      builder: (context, email) {
        final userName = email?.split('@').first ?? 'IT';

        return DashboardShell(
          topBackground: const Stack(
            children: [
              DashboardOrb(
                size: 220,
                top: -90,
                right: -20,
                colors: [Color(0xFFE0E7FF), Color(0xFFB1BEFF)],
              ),
              DashboardOrb(
                size: 170,
                top: 220,
                left: -60,
                colors: [Color(0xFFF0F3FF), Color(0xFFD6DEFF)],
              ),
            ],
          ),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    HomeHeader(
                      userName: userName.toUpperCase(),
                      role: 'IT Administrator',
                    ),
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: DashboardHeroCard(
                        badge: 'Infrastructure Control',
                        badgeIcon: Icons.admin_panel_settings_rounded,
                        title: 'System health is stable and responsive',
                        description:
                            'Monitor platform status, review operational alerts, and manage administrative access with a central control view.',
                        gradient: const [Color(0xFF1B2345), Color(0xFF4C60B8)],
                        trailing: const Icon(
                          Icons.memory_rounded,
                          color: Color(0xFFFFD27A),
                        ),
                        footer: const [
                          HeroMetricChip(value: '99.9%', label: 'Uptime'),
                          HeroMetricChip(value: '14', label: 'Alerts'),
                          HeroMetricChip(value: '4', label: 'Backups'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: ItStatusCard(),
                    ),
                    const SizedBox(height: 28),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: DashboardSectionTitle(
                        title: 'Admin Panel',
                        actionLabel: 'Control',
                        subtitle:
                            'Critical tools for users, settings, logs, and resilience',
                      ),
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.18,
                    children: [
                      QuickActionCard(
                        title: 'User\nManagement',
                        icon: Icons.manage_accounts_outlined,
                        color: Colors.blueGrey,
                        onTap: () {},
                      ),
                      QuickActionCard(
                        title: 'System\nLogs',
                        icon: Icons.terminal_outlined,
                        color: Colors.deepPurple,
                        onTap: () {},
                      ),
                      QuickActionCard(
                        title: 'App\nSettings',
                        icon: Icons.settings_applications_outlined,
                        color: Colors.blue,
                        onTap: () {},
                      ),
                      QuickActionCard(
                        title: 'Database\nBackup',
                        icon: Icons.backup_outlined,
                        color: Colors.redAccent,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 28)),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: DashboardSectionTitle(
                    title: 'Recent Reports',
                    actionLabel: 'Review',
                    subtitle:
                        'Operational items waiting for administrative follow-up',
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 14, 20, 28),
                  child: ItReportsPanel(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
