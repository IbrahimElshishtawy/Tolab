import 'package:flutter/material.dart';

import 'app_admin/app.dart';
import 'app_admin/core/services/app_dependencies.dart';
import 'app_admin/state/store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dependencies = await AppDependencies.initialize();
  final store = createAppStore(dependencies);
  runApp(TolabAdminApp(store: store));
}
