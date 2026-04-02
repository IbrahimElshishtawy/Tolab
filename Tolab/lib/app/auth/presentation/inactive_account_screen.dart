import 'package:flutter/material.dart';

import '../../core/app_scope.dart';

class InactiveAccountScreen extends StatelessWidget {
  const InactiveAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AppScope.auth(context).currentUser;

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
                    'Account inactive',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${user?.email ?? 'This account'} is currently inactive. Contact your administrator to restore access.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () => AppScope.auth(context).logout(),
                    child: const Text('Return to login'),
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
