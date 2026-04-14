import 'package:flutter/material.dart';

import 'app_card.dart';

class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AppCard(child: child),
      ),
    );
  }
}
