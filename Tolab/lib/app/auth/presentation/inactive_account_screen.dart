import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../localization/app_localizations.dart';

class InactiveAccountScreen extends StatelessWidget {
  const InactiveAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AppScope.auth(context).currentUser;
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
                  const Icon(Icons.lock_person_rounded, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    l10n.t('auth.inactive.title'),
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.t(
                      'auth.inactive.description',
                      params: <String, String>{
                        'account': user?.email ??
                            l10n.t('auth.inactive.fallback_account'),
                      },
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () => AppScope.auth(context).logout(),
                    child: Text(l10n.t('common.actions.return_to_login')),
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
