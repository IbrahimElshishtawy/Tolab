import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_scope.dart';
import '../../localization/app_localizations.dart';
import '../../routing/app_routes.dart';

class UnauthorizedScreen extends StatelessWidget {
  const UnauthorizedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AppScope.auth(context);
    final user = auth.currentUser;
    final l10n = context.l10n;

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
                    l10n.t('auth.unauthorized.title'),
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user == null
                        ? l10n.t('auth.unauthorized.anonymous')
                        : l10n.t(
                            'auth.unauthorized.with_role',
                            params: <String, String>{'role': user.role.value},
                          ),
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
                        child: Text(l10n.t('common.actions.go_home')),
                      ),
                      OutlinedButton(
                        onPressed: auth.logout,
                        child: Text(l10n.t('common.actions.logout')),
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
