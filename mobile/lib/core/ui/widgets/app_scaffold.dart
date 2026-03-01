import 'package:flutter/material.dart';
import 'state_view.dart';
import '../tokens/spacing_tokens.dart';

class AppScaffold extends StatelessWidget {
  final String? title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool isLoading;
  final String? error;
  final bool isEmpty;
  final VoidCallback? onRetry;

  const AppScaffold({
    super.key,
    this.title,
    required this.child,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.isLoading = false,
    this.error,
    this.isEmpty = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title != null
          ? AppBar(
              title: Text(title!),
              actions: actions,
            )
          : null,
      body: StateView(
        isLoading: isLoading,
        error: error,
        isEmpty: isEmpty,
        onRetry: onRetry,
        child: child,
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
