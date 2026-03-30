import 'package:flutter/material.dart';

import 'academy_panel_app.dart';
import 'app/core/services/app_dependencies.dart';
import 'app/modules/academy_panel/state/academy_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dependencies = await AppDependencies.initialize();
  final store = createAcademyStore(dependencies);
  runApp(AcademyPanelApp(store: store));
}
