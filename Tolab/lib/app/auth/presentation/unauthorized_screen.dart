import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_scope.dart';
import '../../routing/app_routes.dart';

class UnauthorizedScreen extends StatelessWidget {
  const UnauthorizedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AppScope.auth(context);
    final user = auth.currentUser;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.gpp_bad_rounded, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Unauthorized',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user == null
                        ? 'You do not have access to this area.'
                        : 'Your role "${user.role.value}" does not have access to this route.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      FilledButton(
                        onPressed: () {
                          final currentUser = auth.currentUser;
                          if (currentUser == null) {
                            context.go(UnifiedAppRoutes.login);
                            return;
                          }

                          context.go(
                            UnifiedAppRoutes.homeForRole(currentUser.role),
                          );
                        },
                        child: const Text('Go home'),
                      ),
                      OutlinedButton(
                        onPressed: auth.logout,
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
