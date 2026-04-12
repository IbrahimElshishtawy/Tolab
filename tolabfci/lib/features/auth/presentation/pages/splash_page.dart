import 'package:flutter/material.dart';

import '../../../../core/widgets/loading_widget.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: LoadingWidget(label: 'Preparing your workspace...'),
      ),
    );
  }
}
