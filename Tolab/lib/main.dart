import 'package:flutter/widgets.dart';

import 'admin/config/admin_bootstrap.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdminBootstrap.initialize();
  runApp(const TolabApp());
}
