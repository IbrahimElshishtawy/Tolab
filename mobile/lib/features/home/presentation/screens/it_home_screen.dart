import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:tolab_fci/redux/state/app_state.dart';
import '../widgets/home_header.dart';
import '../widgets/quick_action_card.dart';

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
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border:
                            Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'System Status: Healthy',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[800],
                                  ),
                                ),
                                Text(
                                  'All services are running normally.',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Admin Panel',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    childAspectRatio: 1.3,
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
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Recent Reports',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.bug_report_outlined),
                        ),
                        title: Text('Report #${index + 1024}'),
                        subtitle: const Text('Pending review by IT'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {},
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
}
