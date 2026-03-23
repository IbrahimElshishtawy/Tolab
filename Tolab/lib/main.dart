import 'package:flutter/widgets.dart';

import 'app.dart';
import 'app/config/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.bootstrap();
  runApp(const TolabApp());
}
