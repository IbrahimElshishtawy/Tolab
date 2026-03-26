import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/core/services/app_dependencies.dart';
import 'app/state/store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dependencies = await AppDependencies.initialize();
  final store = createAppStore(dependencies);
  runApp(TolabAdminApp(store: store));
}
