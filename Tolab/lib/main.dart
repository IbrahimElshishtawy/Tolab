import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/bootstrap/app_bootstrap.dart';
import 'app_admin/core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TolabBootstrapApp());
}

class TolabBootstrapApp extends StatefulWidget {
  const TolabBootstrapApp({super.key});

  @override
  State<TolabBootstrapApp> createState() => _TolabBootstrapAppState();
}

class _TolabBootstrapAppState extends State<TolabBootstrapApp> {
  UnifiedAppBootstrap? _bootstrap;
  late Future<UnifiedAppBootstrap> _bootstrapFuture = _loadBootstrap();

  @override
  void dispose() {
    final bootstrap = _bootstrap;
    if (bootstrap != null) {
      Future<void>(() => bootstrap.dispose());
    }
    super.dispose();
  }

  Future<UnifiedAppBootstrap> _loadBootstrap() async {
    final bootstrap = await UnifiedAppBootstrap.initialize();
    _bootstrap = bootstrap;
    return bootstrap;
  }

  Future<void> _retryBootstrap() async {
    final staleBootstrap = _bootstrap;
    _bootstrap = null;
    if (staleBootstrap != null) {
      await staleBootstrap.dispose();
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _bootstrapFuture = _loadBootstrap();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UnifiedAppBootstrap>(
      future: _bootstrapFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _BootstrapShell(child: _BootstrapLoadingScreen());
        }

        if (snapshot.hasError) {
          return _BootstrapShell(
            child: _BootstrapErrorScreen(
              error: snapshot.error,
              onRetry: _retryBootstrap,
            ),
          );
        }

        final bootstrap = snapshot.data;
        if (bootstrap == null) {
          return _BootstrapShell(
            child: _BootstrapErrorScreen(
              error: StateError('App bootstrap returned no data.'),
              onRetry: _retryBootstrap,
            ),
          );
        }

        return TolabApp(bootstrap: bootstrap);
      },
    );
  }
}

class _BootstrapShell extends StatelessWidget {
  const _BootstrapShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      home: child,
    );
  }
}

class _BootstrapLoadingScreen extends StatelessWidget {
  const _BootstrapLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SizedBox(
          width: 42,
          height: 42,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
      ),
    );
  }
}

class _BootstrapErrorScreen extends StatelessWidget {
  const _BootstrapErrorScreen({required this.error, required this.onRetry});

  final Object? error;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, size: 56),
                const SizedBox(height: 16),
                Text(
                  'Unable to start Tolab',
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  '$error',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry startup'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
