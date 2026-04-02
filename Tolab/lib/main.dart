import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'app/bootstrap/app_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final bootstrap = await UnifiedAppBootstrap.initialize();
  runApp(TolabApp(bootstrap: bootstrap));
}
