import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_card.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class LogoutTile extends ConsumerWidget {
  const LogoutTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      child: ListTile(
        title: const Text('Logout'),
        subtitle: const Text('End the current session on this device'),
        trailing: const Icon(Icons.logout_rounded),
        onTap: () => ref.read(authNotifierProvider.notifier).logout(),
      ),
    );
  }
}
