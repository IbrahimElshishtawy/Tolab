// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../../../../redux/app_state.dart';
import '../widgets/home_header.dart';
import '../../../../core/ui/widgets/university_widgets.dart';
import '../../../../core/ui/widgets/business_widgets.dart';
import '../../../../core/ui/tokens/spacing_tokens.dart';
import '../../../../core/ui/tokens/color_tokens.dart';

class ItHomeScreen extends StatelessWidget {
  const ItHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StoreConnector<AppState, String?>(
      converter: (store) => store.state.authState.email,
      builder: (context, email) {
        final userName = email?.split('@').first ?? 'IT';

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HomeHeader(
                    userName: userName.toUpperCase(),
                    role: 'IT Administrator',
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                    child: AppCard(
                      color: AppColors.success.withOpacity(0.05),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.m),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.verified_user_rounded, color: AppColors.success),
                          ),
                          const SizedBox(width: AppSpacing.l),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Infrastructure Secure',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success,
                                  ),
                                ),
                                const Text('All 12 clusters are healthy', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.l),
                    child: SectionHeader(title: 'Admin Command Center'),
                  ),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                    mainAxisSpacing: AppSpacing.m,
                    crossAxisSpacing: AppSpacing.m,
                    childAspectRatio: 1.5,
                    children: [
                      _buildAdminAction(context, 'Users', Icons.manage_accounts_rounded, Colors.blueGrey),
                      _buildAdminAction(context, 'Security', Icons.security_rounded, Colors.deepPurple),
                      _buildAdminAction(context, 'Config', Icons.settings_suggest_rounded, Colors.blue),
                      _buildAdminAction(context, 'Audit', Icons.history_edu_rounded, Colors.redAccent),
                    ],
                  ),
                  const SizedBox(height: 25),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.l),
                    child: SectionHeader(title: 'Critical Alerts'),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                    itemCount: 2,
                    itemBuilder: (context, index) {
                      return AppCard(
                        margin: const EdgeInsets.only(bottom: AppSpacing.m),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            backgroundColor: Colors.redAccent,
                            child: Icon(Icons.priority_high_rounded, color: Colors.white),
                          ),
                          title: Text(index == 0 ? 'Storage Threshold' : 'Auth Gateway Latency'),
                          subtitle: Text(index == 0 ? '92% of server capacity used' : 'Latency increased by 40%'),
                          trailing: const Icon(Icons.chevron_right),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdminAction(BuildContext context, String label, IconData icon, Color color) {
    return AppCard(
      onTap: () {},
      color: color.withOpacity(0.05),
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
