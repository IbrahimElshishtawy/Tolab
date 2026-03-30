import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../state/app_state.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: StoreConnector<AppState, String>(
          converter: (store) {
            if (store.state.bootstrapState.errorMessage != null) {
              return store.state.bootstrapState.errorMessage!;
            }
            return 'Preparing dashboards, permissions, notifications, and session state...';
          },
          builder: (context, message) {
            return ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 88,
                    width: 88,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_mosaic_rounded,
                      color: Colors.white,
                      size: 42,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Tolab Admin Panel',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(message, textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  const CircularProgressIndicator.adaptive(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
