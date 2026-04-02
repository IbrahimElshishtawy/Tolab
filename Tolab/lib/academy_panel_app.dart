import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'app/bootstrap/app_bootstrap.dart';

class AcademyPanelApp extends StatelessWidget {
  const AcademyPanelApp({super.key, required this.bootstrap});

  final UnifiedAppBootstrap bootstrap;

  @override
  Widget build(BuildContext context) {
    return TolabApp(bootstrap: bootstrap);
  }
}
